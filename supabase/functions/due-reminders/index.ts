import "jsr:@supabase/functions-js/edge-runtime.d.ts";

Deno.serve(async (req) => {
  const secret = Deno.env.get("CRON_SECRET");
  const auth = req.headers.get("Authorization") ?? "";
  if (secret && auth !== `Bearer ${secret}`) {
    return new Response("Unauthorized", { status: 401 });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const headers = {
    apikey: serviceKey,
    Authorization: `Bearer ${serviceKey}`,
    "Content-Type": "application/json",
  };

  const due = await fetch(`${supabaseUrl}/rest/v1/rpc/dispatch_due_reminders`, {
    method: "POST",
    headers,
    body: "{}",
  });
  const purge = await fetch(`${supabaseUrl}/rest/v1/rpc/purge_expired_completed_tasks`, {
    method: "POST",
    headers,
    body: "{}",
  });

  return new Response(
    JSON.stringify({
      due: await due.json(),
      purged: await purge.json(),
    }),
    { status: 200, headers: { "Content-Type": "application/json" } },
  );
});
