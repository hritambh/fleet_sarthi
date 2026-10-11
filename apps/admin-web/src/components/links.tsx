import { cn } from '@taxcy/ui';
import { useState, type ReactNode } from 'react';
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router';
import { api, call } from '../lib/api.js';
import type { Driver, Vehicle } from '../lib/api-types.js';
import { ApiError } from '../lib/errors.js';
import { fmtRegistration } from '../lib/format.js';
import { useApiMutation } from '../lib/mutations.js';
import { keys, useDrivers, useVehicles } from '../lib/queries.js';
import { DriverSelect, VehicleSelect } from './shared.js';
import { Badge, Button, Field, InlineError, Modal, Spinner } from './ui.js';

// Drivers ↔ vehicles is many-to-many: a trip may only pair a driver with a vehicle they're
// linked to. These are the pieces for showing and editing those links.

interface CheckOption {
  id: string;
  label: string;
}

/** A labelled list of checkboxes for picking several items. */
export function CheckList({
  legend,
  hint,
  options,
  value,
  onChange,
  empty,
  loading = false,
}: {
  legend: string;
  hint?: ReactNode;
  options: readonly CheckOption[];
  value: readonly string[];
  onChange: (ids: string[]) => void;
  empty: string;
  loading?: boolean;
}) {
  const { t } = useTranslation();
  const selected = new Set(value);
  return (
    <fieldset className="space-y-1">
      <legend className="mb-1 block text-sm font-medium text-slate-700">{legend}</legend>
      {loading ? (
        <Spinner />
      ) : options.length === 0 ? (
        <p className="text-sm text-slate-500">{empty}</p>
      ) : (
        <>
          <div className="max-h-56 overflow-y-auto rounded-md border border-slate-300 bg-white">
            {options.map((option) => (
              <label
                key={option.id}
                className="flex cursor-pointer items-center gap-2 border-b border-slate-100 px-3 py-2 text-sm last:border-b-0 hover:bg-brand-50"
              >
                <input
                  type="checkbox"
                  className="accent-brand-600"
                  checked={selected.has(option.id)}
                  onChange={(e) => {
                    onChange(
                      e.target.checked
                        ? [...value, option.id]
                        : value.filter((id) => id !== option.id),
                    );
                  }}
                />
                {option.label}
              </label>
            ))}
          </div>
          <p className="text-xs text-slate-500">
            {t('fleet.links.selectedCount', { count: value.length })}
          </p>
        </>
      )}
      {hint && <p className="text-xs text-slate-500">{hint}</p>}
    </fieldset>
  );
}

/** Every driver in the org (inactive ones marked), as checkboxes. */
export function DriverCheckList(props: {
  legend: string;
  hint?: ReactNode;
  value: readonly string[];
  onChange: (ids: string[]) => void;
}) {
  const { t } = useTranslation();
  const drivers = useDrivers();
  const options = (drivers.data ?? []).map((d) => ({
    id: d.id,
    label: d.status === 'inactive' ? t('fleet.links.inactiveSuffix', { name: d.name }) : d.name,
  }));
  return (
    <CheckList
      {...props}
      options={options}
      loading={drivers.isPending}
      empty={t('fleet.links.noDriversToPick')}
    />
  );
}

/** Every vehicle in the org (inactive ones marked), as checkboxes. */
export function VehicleCheckList(props: {
  legend: string;
  hint?: ReactNode;
  value: readonly string[];
  onChange: (ids: string[]) => void;
}) {
  const { t } = useTranslation();
  const vehicles = useVehicles();
  const options = (vehicles.data ?? []).map((v) => {
    const name = `${fmtRegistration(v.registrationNo)} · ${v.model}`;
    return {
      id: v.id,
      label: v.status === 'inactive' ? t('fleet.links.inactiveSuffix', { name }) : name,
    };
  });
  return (
    <CheckList
      {...props}
      options={options}
      loading={vehicles.isPending}
      empty={t('fleet.links.noVehiclesToPick')}
    />
  );
}

/** A vehicle's drivers as chips. */
export function DriverChips({ drivers }: { drivers: Vehicle['drivers'] }) {
  const { t } = useTranslation();
  if (drivers.length === 0)
    return <span className="text-sm text-slate-500">{t('fleet.links.noDrivers')}</span>;
  return (
    <span className="flex flex-wrap gap-1">
      {drivers.map((d) => (
        <Badge key={d.id} tone="brand">
          {d.name}
        </Badge>
      ))}
    </span>
  );
}

/** A driver's vehicles as chips linking to each vehicle. */
export function VehicleChips({ vehicles }: { vehicles: Driver['vehicles'] }) {
  const { t } = useTranslation();
  if (vehicles.length === 0)
    return <span className="text-sm text-slate-500">{t('fleet.links.noVehicles')}</span>;
  return (
    <span className="flex flex-wrap gap-1">
      {vehicles.map((v) => (
        <Link key={v.id} to={`/vehicles/${v.id}`} className="hover:underline">
          <Badge tone="brand">{fmtRegistration(v.registrationNo)}</Badge>
        </Link>
      ))}
    </span>
  );
}

/** The error, plus a way to the trips in the way when a link is still in use. */
function LinkError({ error, tripsHref }: { error: unknown; tripsHref: string }) {
  const { t } = useTranslation();
  if (!error) return null;
  return (
    <div className="space-y-1">
      <InlineError error={error} />
      {error instanceof ApiError && error.code === 'LINK_IN_USE' && (
        <Link className="text-sm text-brand-700 hover:underline" to={tripsHref}>
          {t('fleet.links.viewTrips')}
        </Link>
      )}
    </div>
  );
}

function LinkModal({
  title,
  help,
  error,
  busy,
  onSave,
  onClose,
  children,
  tripsHref,
}: {
  title: string;
  help: string;
  error: unknown;
  busy: boolean;
  onSave: () => void;
  onClose: () => void;
  children: ReactNode;
  tripsHref: string;
}) {
  const { t } = useTranslation();
  return (
    <Modal
      open
      onClose={onClose}
      title={title}
      footer={
        <>
          <Button variant="secondary" onClick={onClose}>
            {t('common.cancel')}
          </Button>
          <Button busy={busy} onClick={onSave}>
            {t('common.save')}
          </Button>
        </>
      }
    >
      <div className="space-y-4">
        <p className="text-sm text-slate-600">{help}</p>
        {children}
        <LinkError error={error} tripsHref={tripsHref} />
      </div>
    </Modal>
  );
}

/** Replace the set of drivers who may drive a vehicle. */
export function EditVehicleDriversModal({
  vehicle,
  onClose,
}: {
  vehicle: Pick<Vehicle, 'id' | 'registrationNo' | 'drivers'>;
  onClose: () => void;
}) {
  const { t } = useTranslation();
  const [driverIds, setDriverIds] = useState(() => vehicle.drivers.map((d) => d.id));
  const save = useApiMutation(
    (ids: string[]) =>
      call(
        api.PUT('/vehicles/{id}/drivers', {
          params: { path: { id: vehicle.id } },
          body: { driverIds: ids },
        }),
      ),
    [keys.vehicles, keys.drivers],
  );
  const name = fmtRegistration(vehicle.registrationNo);
  return (
    <LinkModal
      title={t('fleet.links.editDriversTitle', { vehicle: name })}
      help={t('fleet.links.editDriversHelp')}
      error={save.error}
      busy={save.isPending}
      tripsHref={`/trips?vehicleId=${vehicle.id}`}
      onClose={onClose}
      onSave={() => {
        save.mutate(driverIds, { onSuccess: onClose });
      }}
    >
      <DriverCheckList legend={t('fleet.links.drivers')} value={driverIds} onChange={setDriverIds} />
    </LinkModal>
  );
}

/** Replace the set of vehicles a driver may drive. */
export function EditDriverVehiclesModal({
  driver,
  onClose,
}: {
  driver: Pick<Driver, 'id' | 'name' | 'vehicles'>;
  onClose: () => void;
}) {
  const { t } = useTranslation();
  const [vehicleIds, setVehicleIds] = useState(() => driver.vehicles.map((v) => v.id));
  const save = useApiMutation(
    (ids: string[]) =>
      call(
        api.PUT('/drivers/{id}/vehicles', {
          params: { path: { id: driver.id } },
          body: { vehicleIds: ids },
        }),
      ),
    [keys.vehicles, keys.drivers],
  );
  return (
    <LinkModal
      title={t('fleet.links.editVehiclesTitle', { driver: driver.name })}
      help={t('fleet.links.editVehiclesHelp')}
      error={save.error}
      busy={save.isPending}
      tripsHref={`/trips?driverId=${driver.id}`}
      onClose={onClose}
      onSave={() => {
        save.mutate(vehicleIds, { onSuccess: onClose });
      }}
    >
      <VehicleCheckList
        legend={t('fleet.links.vehicles')}
        value={vehicleIds}
        onChange={setVehicleIds}
      />
    </LinkModal>
  );
}

/**
 * Vehicle and driver pickers for a trip that only offer linked pairs: whichever is picked
 * first narrows the other to its links. Picking a new first choice clears an unlinked partner.
 */
export function TripPairFields({
  vehicleId,
  driverId,
  onVehicleChange,
  onDriverChange,
  vehicleLabel,
  driverLabel,
  placeholder,
  hintClassName,
}: {
  vehicleId: string;
  driverId: string;
  onVehicleChange: (id: string) => void;
  onDriverChange: (id: string) => void;
  vehicleLabel: string;
  driverLabel: string;
  placeholder?: string;
  hintClassName?: string;
}) {
  const { t } = useTranslation();
  const vehicles = useVehicles('active');
  const drivers = useDrivers('active');
  // Which side narrows the other; an existing assignment starts from its vehicle.
  const [anchor, setAnchor] = useState<'vehicle' | 'driver'>(
    driverId && !vehicleId ? 'driver' : 'vehicle',
  );
  const [editing, setEditing] = useState<'vehicle' | 'driver' | null>(null);

  const vehicle = vehicles.data?.find((v) => v.id === vehicleId);
  const driver = drivers.data?.find((d) => d.id === driverId);
  const linked = (vId: string, dId: string) =>
    vehicles.data?.find((v) => v.id === vId)?.drivers.some((d) => d.id === dId) ?? false;
  const narrowDrivers = anchor === 'vehicle' && vehicle !== undefined;
  const narrowVehicles = anchor === 'driver' && driver !== undefined;
  const driverOptions = narrowDrivers
    ? (d: Driver) => vehicle.drivers.some((x) => x.id === d.id)
    : undefined;
  const vehicleOptions = narrowVehicles
    ? (v: Vehicle) => v.drivers.some((x) => x.id === driver.id)
    : undefined;
  const noDrivers =
    narrowDrivers && !drivers.isPending && !(drivers.data ?? []).some((d) => driverOptions?.(d));
  const noVehicles =
    narrowVehicles &&
    !vehicles.isPending &&
    !(vehicles.data ?? []).some((v) => vehicleOptions?.(v));

  function pickVehicle(id: string) {
    onVehicleChange(id);
    if (!id) {
      if (driverId) setAnchor('driver');
      return;
    }
    if (anchor === 'vehicle' || !driverId) {
      setAnchor('vehicle');
      if (driverId && !linked(id, driverId)) onDriverChange('');
    }
  }

  function pickDriver(id: string) {
    onDriverChange(id);
    if (!id) {
      if (vehicleId) setAnchor('vehicle');
      return;
    }
    if (anchor === 'driver' || !vehicleId) {
      setAnchor('driver');
      if (vehicleId && !linked(vehicleId, id)) onVehicleChange('');
    }
  }

  const hint = noDrivers
    ? {
        text: t('fleet.links.vehicleHasNoDrivers', {
          vehicle: fmtRegistration(vehicle.registrationNo),
        }),
        action: t('fleet.links.editDrivers'),
        edit: 'vehicle' as const,
      }
    : noVehicles
      ? {
          text: t('fleet.links.driverHasNoVehicles', { driver: driver.name }),
          action: t('fleet.links.editVehicles'),
          edit: 'driver' as const,
        }
      : null;

  return (
    <>
      <Field
        label={vehicleLabel}
        hint={
          narrowVehicles && !noVehicles
            ? t('fleet.links.onlyLinkedVehicles', { driver: driver.name })
            : undefined
        }
      >
        {(props) => (
          <VehicleSelect
            {...props}
            value={vehicleId}
            onChange={pickVehicle}
            filter={vehicleOptions}
            {...(placeholder ? { placeholder } : {})}
          />
        )}
      </Field>
      <Field
        label={driverLabel}
        hint={
          narrowDrivers && !noDrivers
            ? t('fleet.links.onlyLinkedDrivers', {
                vehicle: fmtRegistration(vehicle.registrationNo),
              })
            : undefined
        }
      >
        {(props) => (
          <DriverSelect
            {...props}
            value={driverId}
            onChange={pickDriver}
            filter={driverOptions}
            {...(placeholder ? { placeholder } : {})}
          />
        )}
      </Field>
      {hint && (
        <p
          role="status"
          className={cn(
            'flex flex-wrap items-center gap-2 rounded-md bg-amber-50 px-3 py-2 text-sm text-amber-800',
            hintClassName,
          )}
        >
          {hint.text}
          <Button
            variant="secondary"
            size="sm"
            onClick={() => {
              setEditing(hint.edit);
            }}
          >
            {hint.action}
          </Button>
        </p>
      )}
      {editing === 'vehicle' && vehicle && (
        <EditVehicleDriversModal
          vehicle={vehicle}
          onClose={() => {
            setEditing(null);
          }}
        />
      )}
      {editing === 'driver' && driver && (
        <EditDriverVehiclesModal
          driver={driver}
          onClose={() => {
            setEditing(null);
          }}
        />
      )}
    </>
  );
}
