@ObservedV2
export class AppShellState {
  @Trace showSidebar: boolean = false;
  @Trace showSettings: boolean = false;
  @Trace showAccount: boolean = false;
  @Trace settingsMode: string = 'general';
  @Trace showConnectSheet: boolean = false;

  setSidebarVisible(visible: boolean): void {
    this.showSidebar = visible;
  }

  setSettingsVisible(visible: boolean): void {
    this.showSettings = visible;
    if (!visible) {
      this.showAccount = false;
    }
  }

  openSettings(mode: string): void {
    this.settingsMode = mode;
    this.showSettings = mode !== 'account';
    this.showAccount = mode === 'account';
  }

  setConnectSheetVisible(visible: boolean): void {
    this.showConnectSheet = visible;
  }

  closeGlobalSurfaces(): void {
    this.showSidebar = false;
    this.showSettings = false;
    this.showAccount = false;
    this.showConnectSheet = false;
  }
}
