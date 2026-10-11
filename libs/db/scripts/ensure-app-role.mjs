// Creates (or updates) the roles the API connects as, on a hosted Postgres where
// infra/postgres/init-roles.sql never ran (Neon, Supabase, Render, …). Idempotent;
// run before `prisma migrate deploy`, whose grants name taxcy_app.
//
//   DATABASE_MIGRATION_URL  owner connection (must be allowed to CREATE ROLE)
//   DATABASE_URL            app connection; its user and password become the login role
//
// The login role is made a member of taxcy_app, and must not be a superuser, have
// BYPASSRLS, or be the owner: row-level security has to apply to it.
import pg from 'pg';

const log = (line) => process.stdout.write(`db:roles: ${line}\n`);
const fail = (line) => {
  process.stderr.write(`db:roles: ${line}\n`);
  process.exit(1);
};

const ownerUrl = process.env['DATABASE_MIGRATION_URL'];
const appUrl = process.env['DATABASE_URL'];
if (!ownerUrl || !appUrl) {
  fail('set DATABASE_MIGRATION_URL (owner) and DATABASE_URL (app role)');
}

const app = new URL(appUrl);
const appUser = decodeURIComponent(app.username);
const appPassword = decodeURIComponent(app.password);
const ownerUser = decodeURIComponent(new URL(ownerUrl).username);
if (!appUser || !appPassword) {
  fail('DATABASE_URL must include a user and a password');
}
if (appUser === ownerUser) {
  fail(
    'DATABASE_URL uses the owner role; row-level security would not apply. Use a separate role such as taxcy_api.',
  );
}

const client = new pg.Client({ connectionString: ownerUrl });
await client.connect();
try {
  const exists = async (name) =>
    (await client.query('SELECT 1 FROM pg_roles WHERE rolname = $1', [name])).rowCount > 0;
  const role = client.escapeIdentifier(appUser);
  const password = client.escapeLiteral(appPassword);

  if (!(await exists('taxcy_app'))) {
    await client.query('CREATE ROLE taxcy_app NOLOGIN');
    log('created taxcy_app');
  }
  if (await exists(appUser)) {
    await client.query(`ALTER ROLE ${role} WITH LOGIN PASSWORD ${password}`);
    log(`${appUser} exists; password set from DATABASE_URL`);
  } else {
    await client.query(`CREATE ROLE ${role} WITH LOGIN PASSWORD ${password}`);
    log(`created ${appUser}`);
  }
  await client.query(`GRANT taxcy_app TO ${role}`);

  const { rows } = await client.query(
    'SELECT rolsuper, rolbypassrls FROM pg_roles WHERE rolname = $1',
    [appUser],
  );
  if (rows[0]?.rolsuper || rows[0]?.rolbypassrls) {
    process.stderr.write(
      `db:roles: ${appUser} is a superuser or has BYPASSRLS; RLS would not apply\n`,
    );
    process.exitCode = 1;
  }
} finally {
  await client.end();
}
