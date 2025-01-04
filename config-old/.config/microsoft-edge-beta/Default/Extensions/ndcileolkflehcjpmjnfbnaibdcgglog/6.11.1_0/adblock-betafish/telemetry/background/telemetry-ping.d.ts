export const telemetryNotifier: EventEmitter;
export default Telemetry;
import { EventEmitter } from "../../../adblockplusui/adblockpluschrome/lib/events";
declare class Telemetry extends TelemetryBase {
    scheduleNextPing(): Promise<any>;
    shouldRetrySendPingData(pingData: any, resolve: any, reject: any, retryCount?: number): void;
    retrySendPingData(pingData: any, resolve: any, reject: any, retryCount?: number): Promise<void>;
    sendPingData(pingData: any): Promise<any>;
    pingNow(): Promise<any>;
}
import TelemetryBase from "./telemetry-base";
