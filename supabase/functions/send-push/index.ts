import "jsr:@supabase/functions-js/edge-runtime.d.ts";

type NotificationRow = {
  id: string;
  user_id: string;
  task_id: string | null;
  type: string;
  title: string;
  message: string;
};

const FCM_ENDPOINT =
  "https://fcm.googleapis.com/v1/projects/" +
  Deno.env.get("FIREBASE_PROJECT_ID") +
  "/messages:send";

async function getAccessToken(): Promise<string | null> {
  const email = Deno.env.get("FIREBASE_CLIENT_EMAIL");
  const rawKey = Deno.env.get("FIREBASE_PRIVATE_KEY");
  if (!email || !rawKey) return null;

  const key = rawKey.replaceAll("\\n", "\n");
  const header = { alg: "RS256", typ: "JWT" };
  const now = Math.floor(Date.now() / 1000);
  const payload = {
    iss: email,
    sub: email,
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
  };

  const enc = (obj: unknown) =>
    btoa(JSON.stringify(obj))
      .replaceAll("+", "-")
      .replaceAll("/", "_")
      .replaceAll("=", "");

  const unsigned = `${enc(header)}.${enc(payload)}`;
  const pem = key
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replaceAll("\n", "");
  const binary = Uint8Array.from(atob(pem), (c) => c.charCodeAt(0));
  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    binary,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    cryptoKey,
    new TextEncoder().encode(unsigned),
  );
  const sig = btoa(String.fromCharCode(...new Uint8Array(signature)))
    .replaceAll("+", "-")
    .replaceAll("/", "_")
    .replaceAll("=", "");
  const jwt = `${unsigned}.${sig}`;

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  const json = await res.json();
  return json.access_token ?? null;
}

Deno.serve(async (req) => {
  try {
    const body = await req.json();
    const record = (body.record ?? body) as NotificationRow;
    if (!record?.user_id || !record?.title) {
      return new Response(JSON.stringify({ ok: false, error: "invalid payload" }), {
        status: 400,
      });
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const tokensRes = await fetch(
      `${supabaseUrl}/rest/v1/device_tokens?user_id=eq.${record.user_id}&select=token,platform`,
      {
        headers: {
          apikey: serviceKey,
          Authorization: `Bearer ${serviceKey}`,
        },
      },
    );
    const tokens = (await tokensRes.json()) as { token: string; platform: string }[];
    if (!tokens.length) {
      return new Response(JSON.stringify({ ok: true, sent: 0 }), { status: 200 });
    }

    const accessToken = await getAccessToken();
    if (!accessToken) {
      return new Response(
        JSON.stringify({ ok: false, error: "FCM credentials not configured" }),
        { status: 200 },
      );
    }

    let sent = 0;
    for (const row of tokens) {
      const payload = {
        message: {
          token: row.token,
          notification: { title: record.title, body: record.message },
          data: {
            type: record.type ?? "",
            taskId: record.task_id ?? "",
            notificationId: record.id ?? "",
          },
          android: { priority: "HIGH" },
          apns: { payload: { aps: { sound: "default", badge: 1 } } },
        },
      };
      const res = await fetch(FCM_ENDPOINT, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify(payload),
      });
      if (res.ok) sent += 1;
    }

    return new Response(JSON.stringify({ ok: true, sent }), { status: 200 });
  } catch (error) {
    return new Response(JSON.stringify({ ok: false, error: String(error) }), {
      status: 500,
    });
  }
});
