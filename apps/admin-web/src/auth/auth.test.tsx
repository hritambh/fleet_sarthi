import { screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it, vi } from 'vitest';
import { ApiError } from '../lib/errors.js';
import { PasswordForm } from '../pages/AccountPage.js';
import { fakeAuth, renderWithAuth } from '../test/auth.js';
import { LoginPage } from './LoginPage.js';

const user = () => userEvent.setup();
const PHONE = '+919812345678';

describe('sign in with a password', () => {
  it('is the default, and signs in with the normalised number', async () => {
    const u = user();
    const auth = renderWithAuth(<LoginPage />);
    expect(screen.getByRole('heading', { name: 'Sign in' })).toBeInTheDocument();
    const password = screen.getByLabelText('Password');
    expect(password).toHaveAttribute('type', 'password');
    expect(password).toHaveAttribute('autocomplete', 'current-password');
    expect(screen.getByLabelText('Mobile number')).toHaveAttribute('autocomplete', 'tel-national');

    await u.type(screen.getByLabelText('Mobile number'), '98123 45678');
    await u.type(password, 'correct horse');
    await u.click(screen.getByRole('button', { name: 'Show password' }));
    expect(password).toHaveAttribute('type', 'text');
    await u.click(screen.getByRole('button', { name: 'Sign in' }));
    expect(auth.passwordLogin).toHaveBeenCalledWith(PHONE, 'correct horse');
  });

  it('offers only the number and password: no Google, no SMS-code sign-in', () => {
    renderWithAuth(<LoginPage />);
    expect(screen.queryByRole('button', { name: /Google/ })).not.toBeInTheDocument();
    expect(screen.queryByRole('button', { name: /SMS/ })).not.toBeInTheDocument();
    expect(screen.queryByLabelText('One-time code')).not.toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Sign up' })).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Forgot password?' })).toBeInTheDocument();
  });

  it('says the number or password is wrong, and clears the password', async () => {
    const u = user();
    renderWithAuth(
      <LoginPage />,
      fakeAuth({
        passwordLogin: vi
          .fn()
          .mockRejectedValue(new ApiError(401, 'INVALID_CREDENTIALS', 'Wrong phone or password')),
      }),
    );
    await u.type(screen.getByLabelText('Mobile number'), '9812345678');
    await u.type(screen.getByLabelText('Password'), 'nope-nope');
    await u.click(screen.getByRole('button', { name: 'Sign in' }));
    expect(await screen.findByRole('alert')).toHaveTextContent('Wrong mobile number or password.');
    expect(screen.getByLabelText('Password')).toHaveValue('');
  });

  it('rejects numbers that are not Indian mobiles without calling the API', async () => {
    const u = user();
    const auth = renderWithAuth(<LoginPage />);
    await u.type(screen.getByLabelText('Mobile number'), '12345');
    await u.type(screen.getByLabelText('Password'), 'whatever1');
    await u.click(screen.getByRole('button', { name: 'Sign in' }));
    expect(screen.getByText('Enter a 10-digit Indian mobile number')).toBeInTheDocument();
    expect(auth.passwordLogin).not.toHaveBeenCalled();
  });
});

describe('sign up', () => {
  async function openSignUp(u: ReturnType<typeof user>) {
    await u.click(screen.getByRole('button', { name: 'Sign up' }));
    expect(screen.getByRole('heading', { name: 'Create your account' })).toBeInTheDocument();
  }

  it('takes phone, name and password twice on one screen, with no code', async () => {
    const u = user();
    const auth = renderWithAuth(<LoginPage />);
    await openSignUp(u);
    expect(screen.queryByLabelText('One-time code')).not.toBeInTheDocument();
    expect(screen.queryByRole('button', { name: 'Send code' })).not.toBeInTheDocument();
    expect(screen.getByLabelText('Password')).toHaveAttribute('autocomplete', 'new-password');

    await u.type(screen.getByLabelText('Mobile number'), '98123 45678');
    await u.type(screen.getByLabelText('Your name (optional)'), 'Asha Rao');
    await u.type(screen.getByLabelText('Password'), 'short');
    await u.click(screen.getByRole('button', { name: 'Create account' }));
    expect(screen.getByText('Use at least 8 characters.')).toBeInTheDocument();

    await u.type(screen.getByLabelText('Password'), '-but-longer');
    await u.type(screen.getByLabelText('Confirm password'), 'something else');
    await u.click(screen.getByRole('button', { name: 'Create account' }));
    expect(screen.getByText('The two passwords don’t match.')).toBeInTheDocument();
    expect(auth.signup).not.toHaveBeenCalled();

    await u.clear(screen.getByLabelText('Confirm password'));
    await u.type(screen.getByLabelText('Confirm password'), 'short-but-longer');
    await u.click(screen.getByRole('button', { name: 'Create account' }));
    expect(auth.signup).toHaveBeenCalledWith({
      phone: PHONE,
      password: 'short-but-longer',
      name: 'Asha Rao',
    });
  });

  it('rejects a bad number without calling the API', async () => {
    const u = user();
    const auth = renderWithAuth(<LoginPage />);
    await openSignUp(u);
    await u.type(screen.getByLabelText('Mobile number'), '12345');
    await u.type(screen.getByLabelText('Password'), 'a-good-password');
    await u.type(screen.getByLabelText('Confirm password'), 'a-good-password');
    await u.click(screen.getByRole('button', { name: 'Create account' }));
    expect(screen.getByText('Enter a 10-digit Indian mobile number')).toBeInTheDocument();
    expect(auth.signup).not.toHaveBeenCalled();
  });

  it('leaves the name out when empty, and offers sign-in or reset when the account exists', async () => {
    const u = user();
    const auth = renderWithAuth(
      <LoginPage />,
      fakeAuth({
        signup: vi
          .fn()
          .mockRejectedValue(new ApiError(409, 'ACCOUNT_EXISTS', 'This number already has…')),
      }),
    );
    await openSignUp(u);
    await u.type(screen.getByLabelText('Mobile number'), '98123 45678');
    await u.type(screen.getByLabelText('Password'), 'a-good-password');
    await u.type(screen.getByLabelText('Confirm password'), 'a-good-password');
    await u.click(screen.getByRole('button', { name: 'Create account' }));
    expect(auth.signup).toHaveBeenCalledWith({ phone: PHONE, password: 'a-good-password' });
    expect(await screen.findByRole('alert')).toHaveTextContent(
      'This number already has an account. Log in, or reset your password.',
    );
    expect(screen.getByRole('button', { name: 'Create account' })).toBeDisabled();
    await u.click(screen.getByRole('button', { name: 'Reset password' }));
    expect(screen.getByRole('heading', { name: 'Reset your password' })).toBeInTheDocument();
    // The number carries over.
    expect(screen.getByLabelText('Mobile number')).toHaveValue('98123 45678');
  });

  it('links back to sign in', async () => {
    const u = user();
    renderWithAuth(<LoginPage />);
    await openSignUp(u);
    await u.click(screen.getByRole('button', { name: 'Sign in' }));
    expect(screen.getByRole('heading', { name: 'Sign in' })).toBeInTheDocument();
  });
});

describe('forgot password', () => {
  async function reachCodeStep(u: ReturnType<typeof user>) {
    await u.type(screen.getByLabelText('Mobile number'), '98123 45678');
    await u.click(screen.getByRole('button', { name: 'Forgot password?' }));
    expect(screen.getByRole('heading', { name: 'Reset your password' })).toBeInTheDocument();
    await u.click(screen.getByRole('button', { name: 'Send code' }));
    expect(
      await screen.findByRole('heading', { name: 'Choose a new password' }),
    ).toBeInTheDocument();
  }

  it('sends a code, then takes the code and a new password twice, and signs in', async () => {
    const u = user();
    const auth = renderWithAuth(<LoginPage />);
    await reachCodeStep(u);
    expect(auth.requestOtp).toHaveBeenCalledWith(PHONE);
    expect(
      screen.getByText(
        'Locally and in demo mode, the code is printed in the API log (otp.issued … code=…).',
      ),
    ).toBeInTheDocument();
    expect(screen.getByLabelText('One-time code')).toHaveAttribute('autocomplete', 'one-time-code');
    expect(screen.getByText('Resend code in 30s')).toBeInTheDocument();
    expect(screen.queryByLabelText('Your name (optional)')).not.toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Save and sign in' })).toBeDisabled();

    await u.type(screen.getByLabelText('One-time code'), '12a3456');
    expect(screen.getByLabelText('One-time code')).toHaveValue('123456');
    await u.type(screen.getByLabelText('New password'), 'brand-new-pass');
    await u.type(screen.getByLabelText('Confirm password'), 'different-pass');
    await u.click(screen.getByRole('button', { name: 'Save and sign in' }));
    expect(screen.getByText('The two passwords don’t match.')).toBeInTheDocument();
    expect(auth.resetPassword).not.toHaveBeenCalled();

    await u.clear(screen.getByLabelText('Confirm password'));
    await u.type(screen.getByLabelText('Confirm password'), 'brand-new-pass');
    await u.click(screen.getByRole('button', { name: 'Save and sign in' }));
    expect(auth.resetPassword).toHaveBeenCalledWith({
      phone: PHONE,
      code: '123456',
      password: 'brand-new-pass',
    });
  });

  it('rejects a bad number before sending a code', async () => {
    const u = user();
    const auth = renderWithAuth(<LoginPage />);
    await u.click(screen.getByRole('button', { name: 'Forgot password?' }));
    await u.type(screen.getByLabelText('Mobile number'), '12345');
    await u.click(screen.getByRole('button', { name: 'Send code' }));
    expect(screen.getByText('Enter a 10-digit Indian mobile number')).toBeInTheDocument();
    expect(auth.requestOtp).not.toHaveBeenCalled();
  });

  it('keeps the form when the code is wrong', async () => {
    const u = user();
    renderWithAuth(
      <LoginPage />,
      fakeAuth({
        resetPassword: vi.fn().mockRejectedValue(new ApiError(400, 'OTP_INVALID', 'Wrong code')),
      }),
    );
    await reachCodeStep(u);
    await u.type(screen.getByLabelText('One-time code'), '000000');
    await u.type(screen.getByLabelText('New password'), 'brand-new-pass');
    await u.type(screen.getByLabelText('Confirm password'), 'brand-new-pass');
    await u.click(screen.getByRole('button', { name: 'Save and sign in' }));
    expect(await screen.findByRole('alert')).toHaveTextContent('That code is wrong.');
    expect(screen.getByLabelText('One-time code')).toHaveValue('000000');
  });

  it('lets the code be sent again once the wait is over', async () => {
    const u = user();
    const auth = renderWithAuth(
      <LoginPage />,
      fakeAuth({
        requestOtp: vi.fn().mockResolvedValue({ expiresInSeconds: 300, resendAfterSeconds: 0 }),
      }),
    );
    await reachCodeStep(u);
    await u.click(await screen.findByRole('button', { name: 'Resend code' }));
    expect(auth.requestOtp).toHaveBeenCalledTimes(2);
    expect(await screen.findByText('We sent a new code.')).toBeInTheDocument();
  });

  it('goes back to the number, and back to sign in', async () => {
    const u = user();
    renderWithAuth(<LoginPage />);
    await reachCodeStep(u);
    await u.click(screen.getByRole('button', { name: 'Use a different number' }));
    expect(screen.getByLabelText('Mobile number')).toHaveValue('98123 45678');
    await u.click(screen.getByRole('button', { name: 'Back to sign in' }));
    expect(screen.getByRole('heading', { name: 'Sign in' })).toBeInTheDocument();
  });
});

describe('PasswordForm', () => {
  it('sets a first password without asking for a current one', async () => {
    const u = user();
    const onSubmit = vi.fn().mockResolvedValue(undefined);
    renderWithAuth(<PasswordForm hasPassword={false} username={PHONE} onSubmit={onSubmit} />);
    expect(screen.queryByLabelText('Current password')).not.toBeInTheDocument();
    await u.type(screen.getByLabelText('New password'), 'first-password');
    await u.type(screen.getByLabelText('Confirm password'), 'first-password');
    await u.click(screen.getByRole('button', { name: 'Set password' }));
    expect(onSubmit).toHaveBeenCalledWith({ newPassword: 'first-password' });
    expect(
      await screen.findByText('Password set. Next time you can sign in with it.'),
    ).toBeInTheDocument();
  });

  it('changes it with the current one, and says when that is wrong', async () => {
    const u = user();
    const onSubmit = vi
      .fn()
      .mockRejectedValueOnce(
        new ApiError(401, 'INVALID_CREDENTIALS', 'Your current password is wrong'),
      )
      .mockResolvedValueOnce(undefined);
    renderWithAuth(<PasswordForm hasPassword username={PHONE} onSubmit={onSubmit} />);
    expect(screen.getByRole('button', { name: 'Change password' })).toBeDisabled();
    await u.type(screen.getByLabelText('Current password'), 'old-password');
    await u.type(screen.getByLabelText('New password'), 'new-password');
    await u.type(screen.getByLabelText('Confirm password'), 'new-password');
    await u.click(screen.getByRole('button', { name: 'Change password' }));
    expect(onSubmit).toHaveBeenCalledWith({
      currentPassword: 'old-password',
      newPassword: 'new-password',
    });
    expect(await screen.findByText('Your current password is wrong.')).toBeInTheDocument();

    await u.click(screen.getByRole('button', { name: 'Change password' }));
    expect(await screen.findByText('Password changed.')).toBeInTheDocument();
    expect(screen.getByLabelText('Current password')).toHaveValue('');
  });
});
