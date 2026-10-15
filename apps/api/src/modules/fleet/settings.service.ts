import { Injectable } from '@nestjs/common';
import { AuditSettings, PayRule, WorkflowSettings } from '@taxcy/contracts';
import type { TenantTx } from '@taxcy/db';
import type { PayRule as DomainPayRule } from '@taxcy/domain';
import { definedOnly, type Patch } from '../../platform/patch.js';

// Compile-time check that the API's pay-rule schema matches the domain's type.
type Assert<T extends true> = T;
export type PayRuleMatchesDomain = Assert<PayRule extends DomainPayRule ? true : false>;

export interface OrgSettings {
  audit: AuditSettings;
  payRule: PayRule;
  workflow: WorkflowSettings;
}

@Injectable()
export class SettingsService {
  async get(tx: TenantTx): Promise<OrgSettings> {
    const row = await tx.orgSettings.findUniqueOrThrow({ where: { orgId: tx.orgId } });
    return {
      audit: {
        fuelKSigma: row.fuelKSigma,
        fuelMinCycles: row.fuelMinCycles,
        fuelPctThreshold: row.fuelPctThreshold,
        fuelEwmaAlpha: row.fuelEwmaAlpha,
        odoGpsTolerancePct: row.odoGpsTolerancePct,
        docAlertDays: row.docAlertDays,
      },
      payRule: PayRule.parse(row.driverPayRule),
      workflow: {
        driversCanCreateTrips: row.driversCanCreateTrips,
        driversCanAddCharges: row.driversCanAddCharges,
        fuelReceiptRequired: row.fuelReceiptRequired,
      },
    };
  }

  /** The operating rules alone (read by TripsService and FuelService). */
  async workflow(tx: TenantTx): Promise<WorkflowSettings> {
    return (await this.get(tx)).workflow;
  }

  async updateAudit(tx: TenantTx, patch: Patch<AuditSettings>): Promise<AuditSettings> {
    await tx.orgSettings.update({ where: { orgId: tx.orgId }, data: definedOnly(patch) });
    return (await this.get(tx)).audit;
  }

  /** Changes operating rules; they apply to new trips, charges and fills only. */
  async updateWorkflow(tx: TenantTx, patch: Patch<WorkflowSettings>): Promise<WorkflowSettings> {
    await tx.orgSettings.update({ where: { orgId: tx.orgId }, data: definedOnly(patch) });
    return this.workflow(tx);
  }

  async updatePayRule(tx: TenantTx, rule: PayRule): Promise<PayRule> {
    await tx.orgSettings.update({ where: { orgId: tx.orgId }, data: { driverPayRule: rule } });
    return rule;
  }
}
