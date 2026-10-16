import { z } from 'zod';

// Empty strings in .env mean "not set".
const optional = <T extends z.ZodType>(schema: T) =>
  z.preprocess((v) => (v === '' ? undefined : v), schema.optional());

const Env = z
  .object({
    NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
    PORT: z.coerce.number().int().positive().default(3000),
    LOG_LEVEL: z
      .enum(['fatal', 'error', 'warn', 'info', 'debug', 'trace', 'silent'])
      .default('info'),
    // Origins as the browser sends them: a bare host gets https://, and a trailing
    // slash is dropped (both would otherwise never match).
    CORS_ORIGINS: z
      .string()
      .default('http://localhost:5174')
      .transform((v) =>
        v
          .split(',')
          .map((s) => s.trim().replace(/\/+$/, ''))
          .filter(Boolean)
          .map((s) => (/^https?:\/\//.test(s) ? s : `https://${s}`)),
      ),

    DATABASE_URL: z.url(),
    REDIS_URL: z.url(),

    S3_ENDPOINT: z.url(),
    S3_PUBLIC_ENDPOINT: optional(z.url()),
    S3_REGION: z.string().min(1),
    S3_BUCKET: z.string().min(1),
    S3_ACCESS_KEY_ID: z.string().min(1),
    S3_SECRET_ACCESS_KEY: z.string().min(1),
    S3_UPLOAD_URL_TTL_SECONDS: z.coerce.number().int().positive().default(600),

    JWT_ACCESS_SECRET: z.string().min(32, 'JWT_ACCESS_SECRET must be at least 32 characters'),
    JWT_ACCESS_TTL_SECONDS: z.coerce.number().int().positive().default(900),
    JWT_REFRESH_TTL_DAYS: z.coerce.number().int().positive().default(30),

    OTP_TTL_SECONDS: z.coerce.number().int().positive().default(300),
    OTP_MAX_ATTEMPTS: z.coerce.number().int().positive().default(5),
    /** OTP requests allowed per client IP per hour (shared networks, e.g. a depot's Wi-Fi, need headroom). */
    OTP_IP_LIMIT_PER_HOUR: z.coerce.number().int().positive().default(30),
    /** Sign-ups per client IP per hour (phones aren't verified at sign-up). */
    SIGNUP_IP_LIMIT_PER_HOUR: z.coerce.number().int().positive().default(20),
    SMS_PROVIDER: z.enum(['console']).default('console'),
    /**
     * Phone OTP: sign in without a password, verified sign-up, and password reset.
     * `none` switches it off. `phone_email` uses phone.email (needs
     * PHONE_EMAIL_CLIENT_ID). `stub` accepts tokens like `stub:+919876543210`, for
     * development and tests only (refused in production).
     */
    PHONE_OTP_PROVIDER: z.preprocess(
      (v) => (v === '' ? undefined : v),
      z.enum(['none', 'phone_email', 'stub']).default('none'),
    ),
    /** phone.email client id (Admin Dashboard → Profile Details). */
    PHONE_EMAIL_CLIENT_ID: optional(z.string().min(1)),
    /** phone.email's user lookup, overridable for tests. */
    PHONE_EMAIL_USER_URL: z.url().default('https://eapi.phone.email/getuser'),
    /** Sign-up must prove the number with an OTP (needs a PHONE_OTP_PROVIDER). */
    SIGNUP_REQUIRES_VERIFIED_PHONE: z.preprocess(
      (v) => (v === '' ? undefined : v),
      z.stringbool().default(false),
    ),
    OCR_PROVIDER: z.enum(['stub']).default('stub'),

    /**
     * SPARQL endpoint of the public vehicle catalogue that fills the add-vehicle
     * form's brand and model dropdowns. Overridable for tests and for a mirror.
     */
    VEHICLE_CATALOG_URL: z.url().default('https://query.wikidata.org/sparql'),
    /** MediaWiki API whose category tree decides which cars are on sale here. */
    VEHICLE_CATALOG_WIKI_URL: z.url().default('https://en.wikipedia.org/w/api.php'),
    /** The category that scopes the catalogue to one market. */
    VEHICLE_CATALOG_CATEGORY: z.string().min(1).default('Cars of India'),

    /**
     * Geoapify key behind the trip pickup/drop suggestions (free plan: 3,000
     * requests a day, https://myprojects.geoapify.com). Empty switches place
     * search off: the route answers with no suggestions and typing still works.
     */
    GEOAPIFY_API_KEY: optional(z.string().min(1)),
    /** Geoapify's autocomplete endpoint, overridable for tests. */
    GEOAPIFY_URL: z.url().default('https://api.geoapify.com/v1/geocode/autocomplete'),
    /**
     * Geoapify requests allowed per day (UTC), counting only cache misses. Kept
     * under the free plan's 3,000 so the quota is never overrun; past it,
     * suggestions come from the cache only until midnight UTC.
     */
    GEOAPIFY_DAILY_LIMIT: z.coerce.number().int().positive().default(2_800),

    /**
     * Where background jobs (outbox relay, queue workers, schedules) run. `external`:
     * the workers app. `in-process`: inside the API, for hosts with no free background
     * worker (Render's free plan); run one API instance and no workers app then.
     */
    JOBS_MODE: z.enum(['external', 'in-process']).default('external'),
    /**
     * Demo deployments only. Allows SMS_PROVIDER=console with NODE_ENV=production, so
     * password-reset codes are written to the server log instead of being sent: anyone
     * who can read the logs can reset anyone's password. Logged loudly at startup.
     */
    DEMO_MODE: z.preprocess((v) => (v === '' ? undefined : v), z.stringbool().default(false)),
    /**
     * Demo deployments only. Rebuilds the demo fleets (Sharma Travels, Patil Cabs) for
     * the current IST day when they were seeded on an earlier one: daily at 03:30 IST
     * (`demo.refresh`) and when the API starts (`infra/render/start-api.sh`). Deletes
     * only those two fleets, matched by name and owner phone.
     */
    DEMO_REFRESH_DAILY: z.preprocess(
      (v) => (v === '' ? undefined : v),
      z.stringbool().default(false),
    ),
    /**
     * Testing only. A password that signs in as any existing user and is accepted as
     * the current password when changing anyone's password. Every use is logged.
     * Empty (the default) switches it off; production allows it only with DEMO_MODE.
     */
    MASTER_PASSWORD: optional(
      z.string().min(8, 'MASTER_PASSWORD must be at least 8 characters (or empty to turn it off)'),
    ),

    SENTRY_DSN: optional(z.url()),
  })
  .superRefine((env, ctx) => {
    // `console` is the only SMS provider so far; once a real one exists, this check
    // becomes `SMS_PROVIDER === 'console' && !DEMO_MODE`.
    if (env.NODE_ENV === 'production' && !env.DEMO_MODE) {
      ctx.addIssue({
        code: 'custom',
        path: ['SMS_PROVIDER'],
        message:
          'console only logs password-reset codes; production needs a real SMS provider (or DEMO_MODE=true for a demo that reads codes from the logs)',
      });
    }
    if (env.PHONE_OTP_PROVIDER === 'phone_email' && !env.PHONE_EMAIL_CLIENT_ID) {
      ctx.addIssue({
        code: 'custom',
        path: ['PHONE_EMAIL_CLIENT_ID'],
        message: 'required when PHONE_OTP_PROVIDER=phone_email',
      });
    }
    if (env.NODE_ENV === 'production' && env.PHONE_OTP_PROVIDER === 'stub') {
      ctx.addIssue({
        code: 'custom',
        path: ['PHONE_OTP_PROVIDER'],
        message: 'stub accepts any number without an OTP; production needs phone_email or none',
      });
    }
    if (env.SIGNUP_REQUIRES_VERIFIED_PHONE && env.PHONE_OTP_PROVIDER === 'none') {
      ctx.addIssue({
        code: 'custom',
        path: ['SIGNUP_REQUIRES_VERIFIED_PHONE'],
        message: 'needs a PHONE_OTP_PROVIDER to verify numbers with',
      });
    }
    if (env.NODE_ENV === 'production' && env.MASTER_PASSWORD && !env.DEMO_MODE) {
      ctx.addIssue({
        code: 'custom',
        path: ['MASTER_PASSWORD'],
        message: 'signs in as anyone; production allows it only with DEMO_MODE=true (testing)',
      });
    }
  });

export type AppConfig = z.infer<typeof Env>;

/** Injection token for the validated config. */
export const APP_CONFIG = Symbol('APP_CONFIG');

export function loadConfig(env: NodeJS.ProcessEnv = process.env): AppConfig {
  const result = Env.safeParse(env);
  if (!result.success) {
    const problems = result.error.issues
      .map((i) => `  - ${i.path.join('.') || '(root)'}: ${i.message}`)
      .join('\n');
    throw new Error(
      `Invalid environment configuration:\n${problems}\nSee .env.example and docs/development.md.`,
    );
  }
  return result.data;
}
