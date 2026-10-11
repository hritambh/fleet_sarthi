import { screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { useState } from 'react';
import { MemoryRouter } from 'react-router';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import type * as ApiModule from '../lib/api.js';
import type { Driver, Vehicle } from '../lib/api-types.js';
import { renderWithAuth } from '../test/auth.js';
import { EditDriverVehiclesModal, EditVehicleDriversModal, TripPairFields } from './links.js';

// The API client is replaced by mocks answering from the fixtures below.
const { api } = vi.hoisted(() => ({ api: { GET: vi.fn(), POST: vi.fn(), PUT: vi.fn() } }));
vi.mock('../lib/api.js', async (importOriginal) => ({
  ...(await importOriginal<typeof ApiModule>()),
  api,
}));

const ok = (data: unknown) => Promise.resolve({ data, response: new Response(null) });
const fail = (status: number, error: unknown) =>
  Promise.resolve({ error, response: new Response(null, { status }) });

const V1 = '0199c7a2-5b7e-7c3d-9f00-1a2b3c4d5e01';
const V2 = '0199c7a2-5b7e-7c3d-9f00-1a2b3c4d5e02';
const RAMESH = '0199c7a2-5b7e-7c3d-9f00-1a2b3c4d5e11';
const SURESH = '0199c7a2-5b7e-7c3d-9f00-1a2b3c4d5e12';

const vehicle = (overrides: Partial<Vehicle>): Vehicle => ({
  id: V1,
  registrationNo: 'MH12AB1234',
  make: 'Maruti',
  model: 'Dzire',
  year: 2022,
  fuelType: 'cng',
  vehicleModelId: null,
  lastOdometerKm: 48_210,
  status: 'active',
  drivers: [],
  createdAt: '2026-10-01T05:00:00.000Z',
  ...overrides,
});

const driver = (overrides: Partial<Driver>): Driver => ({
  id: RAMESH,
  userId: '0199c7a2-5b7e-7c3d-9f00-1a2b3c4d5e21',
  name: 'Ramesh Kumar',
  phone: '+919812345678',
  status: 'active',
  membershipStatus: 'active',
  payRule: null,
  vehicles: [],
  createdAt: '2026-10-01T05:00:00.000Z',
  ...overrides,
});

const vehicles = [
  vehicle({ drivers: [{ id: RAMESH, name: 'Ramesh Kumar' }] }),
  vehicle({ id: V2, registrationNo: 'MH12CD5678', model: 'Ertiga', drivers: [] }),
];
const drivers = [
  driver({ vehicles: [{ id: V1, registrationNo: 'MH12AB1234' }] }),
  driver({ id: SURESH, name: 'Suresh Patil', vehicles: [] }),
];

beforeEach(() => {
  api.GET.mockReset().mockImplementation((path: string) =>
    path === '/vehicles' ? ok(vehicles) : path === '/drivers' ? ok(drivers) : ok([]),
  );
  api.PUT.mockReset();
});

const options = (select: HTMLElement) =>
  within(select)
    .getAllByRole('option')
    .map((o) => o.textContent);

describe('EditVehicleDriversModal', () => {
  it('starts from the linked drivers and saves the new set', async () => {
    api.PUT.mockImplementation((_path: string, init: { body: { driverIds: string[] } }) =>
      ok({ ...vehicles[0], drivers: init.body.driverIds.map((id) => ({ id, name: id })) }),
    );
    const onClose = vi.fn();
    renderWithAuth(
      <MemoryRouter>
        <EditVehicleDriversModal vehicle={vehicles[0] ?? vehicle({})} onClose={onClose} />
      </MemoryRouter>,
    );
    expect(screen.getByRole('heading', { name: 'Drivers of MH 12 AB 1234' })).toBeInTheDocument();
    expect(await screen.findByRole('checkbox', { name: 'Ramesh Kumar' })).toBeChecked();
    expect(screen.getByRole('checkbox', { name: 'Suresh Patil' })).not.toBeChecked();
    expect(screen.getByText('1 selected')).toBeInTheDocument();

    await userEvent.click(screen.getByRole('checkbox', { name: 'Suresh Patil' }));
    await userEvent.click(screen.getByRole('checkbox', { name: 'Ramesh Kumar' }));
    await userEvent.click(screen.getByRole('button', { name: 'Save' }));

    expect(api.PUT).toHaveBeenCalledWith('/vehicles/{id}/drivers', {
      params: { path: { id: V1 } },
      body: { driverIds: [SURESH] },
    });
    await vi.waitFor(() => {
      expect(onClose).toHaveBeenCalled();
    });
  });
});

describe('EditDriverVehiclesModal', () => {
  it('explains LINK_IN_USE with the trip count and links to the trips', async () => {
    api.PUT.mockReturnValue(
      fail(409, {
        error: {
          code: 'LINK_IN_USE',
          message: 'Reassign or finish the 2 assigned or running trip(s)',
          details: { tripIds: ['t1', 't2'] },
        },
      }),
    );
    const onClose = vi.fn();
    renderWithAuth(
      <MemoryRouter>
        <EditDriverVehiclesModal driver={drivers[0] ?? driver({})} onClose={onClose} />
      </MemoryRouter>,
    );
    const linked = await screen.findByRole('checkbox', { name: 'MH 12 AB 1234 · Dzire' });
    expect(linked).toBeChecked();
    await userEvent.click(linked);
    await userEvent.click(screen.getByRole('button', { name: 'Save' }));

    expect(api.PUT).toHaveBeenCalledWith('/drivers/{id}/vehicles', {
      params: { path: { id: RAMESH } },
      body: { vehicleIds: [] },
    });
    expect(await screen.findByRole('alert')).toHaveTextContent(
      'A driver and vehicle you’re unlinking still have 2 assigned or running trips together. Reassign or finish 2 trips first.',
    );
    expect(screen.getByRole('link', { name: 'View the trips' })).toHaveAttribute(
      'href',
      `/trips?driverId=${RAMESH}`,
    );
    expect(onClose).not.toHaveBeenCalled();
  });
});

function Pair({ initial = { vehicleId: '', driverId: '' } }) {
  const [vehicleId, setVehicleId] = useState(initial.vehicleId);
  const [driverId, setDriverId] = useState(initial.driverId);
  return (
    <MemoryRouter>
      <TripPairFields
        vehicleId={vehicleId}
        driverId={driverId}
        onVehicleChange={setVehicleId}
        onDriverChange={setDriverId}
        vehicleLabel="Vehicle"
        driverLabel="Driver"
      />
    </MemoryRouter>
  );
}

describe('TripPairFields', () => {
  it('offers only the chosen vehicle’s drivers, and clears an unlinked driver', async () => {
    renderWithAuth(<Pair />);
    const vehicleSelect = screen.getByLabelText('Vehicle');
    const driverSelect = screen.getByLabelText('Driver');
    await vi.waitFor(() => {
      expect(options(driverSelect)).toEqual(['Select a driver', 'Ramesh Kumar', 'Suresh Patil']);
    });

    await userEvent.selectOptions(vehicleSelect, V1);
    expect(options(driverSelect)).toEqual(['Select a driver', 'Ramesh Kumar']);
    expect(screen.getByText('Only drivers linked to MH 12 AB 1234.')).toBeInTheDocument();
    await userEvent.selectOptions(driverSelect, RAMESH);
    expect(driverSelect).toHaveValue(RAMESH);

    // A vehicle Ramesh isn't linked to: he's cleared, and the empty vehicle gets a hint.
    await userEvent.selectOptions(vehicleSelect, V2);
    expect(driverSelect).toHaveValue('');
    expect(options(driverSelect)).toEqual(['Select a driver']);
    expect(screen.getByRole('status')).toHaveTextContent(
      'No active drivers are linked to MH 12 CD 5678 yet.',
    );
    await userEvent.click(screen.getByRole('button', { name: 'Edit drivers' }));
    expect(
      await screen.findByRole('heading', { name: 'Drivers of MH 12 CD 5678' }),
    ).toBeInTheDocument();
  });

  it('narrows the vehicles to the driver’s when the driver is picked first', async () => {
    renderWithAuth(<Pair />);
    const vehicleSelect = screen.getByLabelText('Vehicle');
    const driverSelect = screen.getByLabelText('Driver');
    await vi.waitFor(() => {
      expect(options(driverSelect)).toHaveLength(3);
    });

    await userEvent.selectOptions(driverSelect, RAMESH);
    expect(options(vehicleSelect)).toEqual(['Select a vehicle', 'MH 12 AB 1234 · Dzire']);
    expect(screen.getByText('Only vehicles linked to Ramesh Kumar.')).toBeInTheDocument();
    // The vehicle choice then doesn't narrow the drivers back.
    await userEvent.selectOptions(vehicleSelect, V1);
    expect(options(driverSelect)).toHaveLength(3);

    await userEvent.selectOptions(vehicleSelect, '');
    await userEvent.selectOptions(driverSelect, SURESH);
    expect(options(vehicleSelect)).toEqual(['Select a vehicle']);
    expect(screen.getByRole('status')).toHaveTextContent(
      'No active vehicles are linked to Suresh Patil yet.',
    );
    expect(screen.getByRole('button', { name: 'Edit vehicles' })).toBeInTheDocument();
  });

  it('keeps an existing assignment as it is', async () => {
    renderWithAuth(<Pair initial={{ vehicleId: V1, driverId: RAMESH }} />);
    await vi.waitFor(() => {
      expect(screen.getByLabelText('Driver')).toHaveValue(RAMESH);
    });
    expect(screen.getByLabelText('Vehicle')).toHaveValue(V1);
    expect(options(screen.getByLabelText('Driver'))).toEqual(['Select a driver', 'Ramesh Kumar']);
  });
});
