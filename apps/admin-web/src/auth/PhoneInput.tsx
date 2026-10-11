import type { InputHTMLAttributes } from 'react';
import { useTranslation } from 'react-i18next';
import { Field, Input } from '../components/ui.js';

/** A 10-digit Indian mobile, with the +91 shown in front. */
export function PhoneInput(props: InputHTMLAttributes<HTMLInputElement>) {
  return (
    <div className="flex">
      <span className="inline-flex items-center rounded-l-md border border-r-0 border-slate-300 bg-brand-50 px-3 text-sm font-medium text-brand-700">
        +91
      </span>
      <Input
        {...props}
        type="tel"
        className="rounded-l-none"
        inputMode="tel"
        autoComplete="tel-national"
        placeholder="98123 45678"
      />
    </div>
  );
}

/** The "Mobile number" field every signed-out screen starts with. */
export function PhoneField({
  value,
  onChange,
  invalid,
  autoFocus = false,
}: {
  value: string;
  onChange: (value: string) => void;
  /** Shows "Enter a 10-digit Indian mobile number" under the field. */
  invalid: boolean;
  autoFocus?: boolean;
}) {
  const { t } = useTranslation();
  return (
    <Field label={t('auth.mobileNumber')} error={invalid ? t('auth.invalidMobile') : null}>
      {(props) => (
        <PhoneInput
          {...props}
          value={value}
          onChange={(e) => {
            onChange(e.target.value);
          }}
          autoFocus={autoFocus}
        />
      )}
    </Field>
  );
}
