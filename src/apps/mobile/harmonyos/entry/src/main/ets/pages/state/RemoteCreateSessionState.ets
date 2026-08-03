import { RecentWorkspaceEntry } from '../../model/RemoteModels';
import { CloudAccountDevice } from '../../services/CloudAccountClient';

@ObservedV2
export class RemoteCreateSessionState {
  @Trace draft: string = '';
  @Trace devices: CloudAccountDevice[] = [];
  @Trace workspaces: RecentWorkspaceEntry[] = [];
  @Trace selectedDeviceId: string = '';
  @Trace selectedDeviceName: string = '';
  @Trace selectedWorkspacePath: string = '';
  @Trace selectedWorkspaceName: string = '';
  @Trace openMenu: string = 'none';
  @Trace isLoadingDevices: boolean = false;
  @Trace isLoadingWorkspaces: boolean = false;
  @Trace isSubmitting: boolean = false;
  @Trace errorText: string = '';

  prepare(deviceId: string, deviceName: string): void {
    this.draft = '';
    this.devices = [];
    this.workspaces = [];
    this.selectedDeviceId = deviceId;
    this.selectedDeviceName = deviceName;
    this.selectedWorkspacePath = '';
    this.selectedWorkspaceName = '';
    this.openMenu = 'none';
    this.isLoadingDevices = false;
    this.isLoadingWorkspaces = false;
    this.isSubmitting = false;
    this.errorText = '';
  }

  setDraft(draft: string): void {
    this.draft = draft;
    this.errorText = '';
  }

  setDevices(devices: CloudAccountDevice[]): void {
    this.devices = devices.slice();
    this.isLoadingDevices = false;
  }

  setWorkspaces(workspaces: RecentWorkspaceEntry[]): void {
    this.workspaces = workspaces.slice();
    this.isLoadingWorkspaces = false;
  }

  selectDevice(device: CloudAccountDevice): void {
    this.selectedDeviceId = device.deviceId;
    this.selectedDeviceName = device.deviceName;
    this.clearWorkspace();
    this.openMenu = 'none';
    this.errorText = '';
  }

  selectWorkspace(workspace?: RecentWorkspaceEntry): void {
    this.selectedWorkspacePath = workspace?.path || '';
    this.selectedWorkspaceName = workspace?.name || '';
    this.openMenu = 'none';
    this.errorText = '';
  }

  clearWorkspace(): void {
    this.selectedWorkspacePath = '';
    this.selectedWorkspaceName = '';
  }

  toggleMenu(menu: string): void {
    this.openMenu = this.openMenu === menu ? 'none' : menu;
  }

  closeMenu(): void {
    this.openMenu = 'none';
  }
}
