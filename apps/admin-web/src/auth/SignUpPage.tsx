import { useState, type SubmitEvent } from 'react';
import { useTranslation } from 'react-i18next';
import { NewPasswordFields } from '../components/PasswordInput.js';
import { Button, Field, InlineError, Input } from '../components/ui.js';
import { ApiError } from '../lib/errors.js';
import { parseIndianMobile } from '../lib/labels.js';
import { AuthShell, LinkButton } from './AuthShell.js';
import { useAuth } from './context.js';
import { passwordProblem, type PasswordProblem } from './password-rules.js';
import { PhoneField } from './PhoneInput.js';

/**
 * Sign up with a mobile number, an optional name and a password (typed twice). An
 * invited number joins its fleet; a number that already has a password is told so.
 */
export function SignUpPage({
  phoneInput,
  onPhoneInput,
  onSignIn,
  onReset,
}: {
  phoneInput: string;
  onPhoneInput: (value: string) => void;
  onSignIn: () => void;
  onReset: () => void;
}) {
  const { t } = useTranslation();
  const auth = useAuth();
  const [name, setName] = useState('');
  const [password, setPassword] = useState('');
  const [confirm, setConfirm] = useState('');
  const [phoneInvalid, setPhoneInvalid] = useState(false);
  const [problem, setProblem] = useState<PasswordProblem | null>(null);
  const [error, setError] = useState<unknown>(null);
  const [busy, setBusy] = useState(false);

  async function submit(event: SubmitEvent<HTMLFormElement>) {
    event.preventDefault();
    const phone = parseIndianMobile(phoneInput);
    const found = passwordProblem(password, confirm);
    setPhoneInvalid(!phone);
    setProblem(found);
    if (!phone || found) return;
    setBusy(true);
    setError(null);
    try {
      const trimmed = name.trim();
      await auth.signup({ phone, password, ...(trimmed ? { name: trimmed } : {}) });
    } catch (e) {
      setError(e);
    } finally {
      setBusy(false);
    }
  }

  const accountExists = error instanceof ApiError && error.code === 'ACCOUNT_EXISTS';

  return (
    <AuthShell title={t('auth.signUpTitle')} subtitle={t('auth.signUpSubtitle')}>
      <form onSubmit={(e) => void submit(e)} className="space-y-4" noValidate>
        <PhoneField
          value={phoneInput}
          onChange={(value) => {
            onPhoneInput(value);
            setError(null);
          }}
          invalid={phoneInvalid}
          autoFocus
        />
        <Field label={t('auth.yourName')}>
          {(props) => (
            <Input
              {...props}
              autoComplete="name"
              maxLength={100}
              placeholder={t('auth.namePlaceholder')}
              value={name}
              onChange={(e) => {
                setName(e.target.value);
              }}
            />
          )}
        </Field>
        <NewPasswordFields
          password={password}
          confirm={confirm}
          onPassword={setPassword}
          onConfirm={setConfirm}
          problem={problem}
          passwordLabel={t('auth.password')}
        />
        <InlineError error={error} />
        {accountExists && (
          <div className="flex gap-2">
            <Button variant="secondary" className="flex-1" onClick={onSignIn}>
              {t('auth.signInButton')}
            </Button>
            <Button variant="secondary" className="flex-1" onClick={onReset}>
              {t('auth.resetPassword')}
            </Button>
          </div>
        )}
        <Button type="submit" busy={busy} disabled={accountExists} className="w-full">
          {t('auth.createAccount')}
        </Button>
      </form>
      <div className="mt-5 text-center text-sm text-slate-600">
        {t('auth.haveAccount')} <LinkButton onClick={onSignIn}>{t('auth.signInButton')}</LinkButton>
      </div>
    </AuthShell>
  );
}
