import { useState, type ReactNode, type SubmitEvent } from 'react';
import { useTranslation } from 'react-i18next';
import { PasswordInput } from '../components/PasswordInput.js';
import { Button, Field, InlineError } from '../components/ui.js';
import { ApiError } from '../lib/errors.js';
import { parseIndianMobile } from '../lib/labels.js';
import { AuthShell, LinkButton } from './AuthShell.js';
import { useAuth } from './context.js';
import { PhoneField } from './PhoneInput.js';
import { ResetPasswordPage } from './ResetPasswordPage.js';
import { SignUpPage } from './SignUpPage.js';

type Screen = 'signin' | 'signup' | 'reset';

/**
 * Signed out: mobile number + password, with sign-up and a forgotten password as the
 * other screens. The number typed carries across screens.
 */
export function LoginPage() {
  const { t } = useTranslation();
  const [screen, setScreen] = useState<Screen>('signin');
  const [phoneInput, setPhoneInput] = useState('');
  const go = (next: Screen) => () => {
    setScreen(next);
  };
  const phone = { phoneInput, onPhoneInput: setPhoneInput };

  switch (screen) {
    case 'signin':
      return (
        <PasswordSignIn
          {...phone}
          onForgot={go('reset')}
          footer={
            <div className="mt-5 text-center text-sm text-slate-600">
              {t('auth.noAccount')}{' '}
              <LinkButton onClick={go('signup')}>{t('auth.signUp')}</LinkButton>
            </div>
          }
        />
      );
    case 'signup':
      return <SignUpPage {...phone} onSignIn={go('signin')} onReset={go('reset')} />;
    case 'reset':
      return <ResetPasswordPage {...phone} onSignIn={go('signin')} />;
  }
}

function PasswordSignIn({
  phoneInput,
  onPhoneInput,
  onForgot,
  footer,
}: {
  phoneInput: string;
  onPhoneInput: (value: string) => void;
  onForgot: () => void;
  footer: ReactNode;
}) {
  const { t } = useTranslation();
  const auth = useAuth();
  const [password, setPassword] = useState('');
  const [error, setError] = useState<unknown>(null);
  const [busy, setBusy] = useState(false);
  const [phoneInvalid, setPhoneInvalid] = useState(false);

  async function submit(event: SubmitEvent<HTMLFormElement>) {
    event.preventDefault();
    const phone = parseIndianMobile(phoneInput);
    setPhoneInvalid(!phone);
    if (!phone) return;
    setBusy(true);
    setError(null);
    try {
      await auth.passwordLogin(phone, password);
    } catch (e) {
      setError(e);
      if (e instanceof ApiError && e.code === 'INVALID_CREDENTIALS') setPassword('');
    } finally {
      setBusy(false);
    }
  }

  return (
    <AuthShell title={t('auth.signIn')} subtitle={t('auth.signInSubtitle')}>
      <form onSubmit={(e) => void submit(e)} className="space-y-4" noValidate>
        <PhoneField value={phoneInput} onChange={onPhoneInput} invalid={phoneInvalid} autoFocus />
        <Field label={t('auth.password')}>
          {(props) => (
            <PasswordInput
              {...props}
              autoComplete="current-password"
              value={password}
              onChange={(e) => {
                setPassword(e.target.value);
              }}
            />
          )}
        </Field>
        <div className="-mt-2 flex justify-end text-sm">
          <LinkButton onClick={onForgot}>{t('auth.forgotPassword')}</LinkButton>
        </div>
        <InlineError error={error} />
        <Button type="submit" busy={busy} disabled={password === ''} className="w-full">
          {t('auth.signInButton')}
        </Button>
      </form>
      {footer}
    </AuthShell>
  );
}
