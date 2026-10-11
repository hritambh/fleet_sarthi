import { useState, type SubmitEvent } from 'react';
import { useTranslation } from 'react-i18next';
import { NewPasswordFields } from '../components/PasswordInput.js';
import { Button, Field, InlineError, Input } from '../components/ui.js';
import { fmtPhone } from '../lib/format.js';
import { parseIndianMobile } from '../lib/labels.js';
import { AuthShell, LinkButton } from './AuthShell.js';
import { useAuth } from './context.js';
import { passwordProblem, type PasswordProblem } from './password-rules.js';
import { PhoneField } from './PhoneInput.js';
import { useSecondsLeft } from './use-seconds-left.js';

/** A code was sent to `phone`; another can be asked for at `resendAt` (a Date.now() time). */
interface CodeSent {
  phone: string;
  resendAt: number;
}

/**
 * Forgot password: mobile number → "Send code", then the code and a new password
 * (typed twice). Saving signs the user in.
 */
export function ResetPasswordPage({
  phoneInput,
  onPhoneInput,
  onSignIn,
}: {
  phoneInput: string;
  onPhoneInput: (value: string) => void;
  onSignIn: () => void;
}) {
  const { t } = useTranslation();
  const auth = useAuth();
  const [sent, setSent] = useState<CodeSent | null>(null);
  const [phoneInvalid, setPhoneInvalid] = useState(false);
  const [code, setCode] = useState('');
  const [password, setPassword] = useState('');
  const [confirm, setConfirm] = useState('');
  const [problem, setProblem] = useState<PasswordProblem | null>(null);
  const [error, setError] = useState<unknown>(null);
  const [resent, setResent] = useState(false);
  const [busy, setBusy] = useState(false);

  async function request(phone: string): Promise<boolean> {
    setBusy(true);
    setError(null);
    try {
      const { resendAfterSeconds } = await auth.requestOtp(phone);
      setSent({ phone, resendAt: Date.now() + resendAfterSeconds * 1000 });
      return true;
    } catch (e) {
      setError(e);
      return false;
    } finally {
      setBusy(false);
    }
  }

  async function sendCode(event: SubmitEvent<HTMLFormElement>) {
    event.preventDefault();
    const phone = parseIndianMobile(phoneInput);
    setPhoneInvalid(!phone);
    if (phone) await request(phone);
  }

  async function save(event: SubmitEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!sent) return;
    const found = passwordProblem(password, confirm);
    setProblem(found);
    setResent(false);
    if (found) return;
    setBusy(true);
    setError(null);
    try {
      await auth.resetPassword({ phone: sent.phone, code, password });
    } catch (e) {
      setError(e);
    } finally {
      setBusy(false);
    }
  }

  if (!sent) {
    return (
      <AuthShell title={t('auth.resetTitle')} subtitle={t('auth.resetSubtitle')}>
        <form onSubmit={(e) => void sendCode(e)} className="space-y-4" noValidate>
          <PhoneField value={phoneInput} onChange={onPhoneInput} invalid={phoneInvalid} autoFocus />
          <InlineError error={error} />
          <Button type="submit" busy={busy} className="w-full">
            {t('auth.sendCode')}
          </Button>
        </form>
        <div className="mt-5 text-center text-sm">
          <LinkButton onClick={onSignIn}>{t('auth.backToSignIn')}</LinkButton>
        </div>
      </AuthShell>
    );
  }

  return (
    <AuthShell
      title={t('auth.newPasswordTitle')}
      subtitle={t('auth.codeSent', { phone: fmtPhone(sent.phone) })}
    >
      <form onSubmit={(e) => void save(e)} className="space-y-4" noValidate>
        {/* Lets password managers save the new password against the number. */}
        <input
          type="text"
          name="username"
          autoComplete="username"
          value={sent.phone}
          readOnly
          hidden
        />
        <Field label={t('auth.oneTimeCode')} hint={t('auth.devCodeHint')}>
          {(props) => (
            <Input
              {...props}
              inputMode="numeric"
              autoComplete="one-time-code"
              maxLength={6}
              placeholder="123456"
              value={code}
              onChange={(e) => {
                setCode(e.target.value.replace(/\D/g, ''));
              }}
              autoFocus
            />
          )}
        </Field>
        <NewPasswordFields
          password={password}
          confirm={confirm}
          onPassword={setPassword}
          onConfirm={setConfirm}
          problem={problem}
        />
        <InlineError error={error} />
        {resent && (
          <p className="text-sm text-emerald-700" role="status">
            {t('auth.codeResent')}
          </p>
        )}
        <Button type="submit" busy={busy} disabled={code.length !== 6} className="w-full">
          {t('auth.saveAndSignIn')}
        </Button>
        <div className="flex flex-wrap items-center justify-between gap-2 text-sm">
          <ResendButton
            resendAt={sent.resendAt}
            disabled={busy}
            onResend={async () => {
              setCode('');
              setResent(await request(sent.phone));
            }}
          />
          <LinkButton
            onClick={() => {
              setSent(null);
              setCode('');
              setError(null);
              setResent(false);
            }}
          >
            {t('auth.differentNumber')}
          </LinkButton>
        </div>
      </form>
    </AuthShell>
  );
}

function ResendButton({
  resendAt,
  disabled,
  onResend,
}: {
  resendAt: number;
  disabled: boolean;
  onResend: () => Promise<void>;
}) {
  const { t } = useTranslation();
  const seconds = useSecondsLeft(resendAt);
  if (seconds > 0) return <span className="text-slate-500">{t('auth.resendIn', { seconds })}</span>;
  return (
    <button
      type="button"
      disabled={disabled}
      onClick={() => void onResend()}
      className="rounded-sm font-medium text-brand-700 hover:text-brand-900 hover:underline focus-visible:outline-2 focus-visible:outline-brand-500 disabled:text-slate-400"
    >
      {t('auth.resendCode')}
    </button>
  );
}
