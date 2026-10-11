import { Global, Module } from '@nestjs/common';
import { DiscoveryModule } from '@nestjs/core';
import { JobDispatcher } from './job-dispatcher.js';
import { JobRunner } from './job-runner.js';
import { OutboxRelay } from './outbox-relay.js';

@Global()
@Module({
  imports: [DiscoveryModule],
  providers: [JobDispatcher, OutboxRelay, JobRunner],
  exports: [JobDispatcher, OutboxRelay, JobRunner],
})
export class JobsModule {}
