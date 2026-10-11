-- Google sign-in was removed: phone + password only.
-- DropIndex
DROP INDEX "users_google_sub_key";

-- AlterTable
ALTER TABLE "users" DROP COLUMN "email",
DROP COLUMN "google_sub";

