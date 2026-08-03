import {
  AppNavigationBackAction,
  AppNavigationPathSpec,
  AppRoute,
  AppRouteContract
} from '../navigation/AppRouteContract';
import { AppShellState } from './AppShellState';

/** Owns application navigation and global overlay state. */
export class AppShellViewModel {
  readonly state: AppShellState = new AppShellState();
  readonly navigationStack: NavPathStack = new NavPathStack();

  currentRoute(): AppRoute {
    return AppRouteContract.currentRoute(this.navigationStack.getAllPathName());
  }

  isRoute(route: AppRoute): boolean {
    return this.currentRoute() === route;
  }

  isGeneralChatVisible(): boolean {
    return AppRouteContract.isGeneralComposerRoute(this.currentRoute());
  }

  pushRoute(route: AppRoute, sessionId: string = '', animated: boolean = true): void {
    const spec: AppNavigationPathSpec | undefined = AppRouteContract.pathSpec(
      this.currentRoute(),
      route,
      sessionId
    );
    if (!spec) {
      return;
    }
    if (spec.hasSessionParam()) {
      this.navigationStack.pushPath({ name: spec.name, param: spec.routeParam() }, animated);
      return;
    }
    this.navigationStack.pushPath({ name: spec.name }, animated);
  }

  replaceRoute(route: AppRoute, sessionId: string = ''): void {
    this.navigationStack.clear();
    if (route !== AppRoute.ChatHome) {
      this.pushRoute(route, sessionId);
    }
  }

  replaceRouteWithoutAnimation(route: AppRoute, sessionId: string = ''): void {
    this.navigationStack.clear(false);
    if (route !== AppRoute.ChatHome) {
      this.pushRoute(route, sessionId, false);
    }
  }

  replaceCurrentRoute(route: AppRoute, sessionId: string = ''): void {
    if (this.navigationStack.getAllPathName().length === 0) {
      this.pushRoute(route, sessionId);
      return;
    }
    if (sessionId.length > 0) {
      this.navigationStack.replacePath({
        name: route,
        param: AppRouteContract.routeParam(sessionId)
      }, false);
      return;
    }
    this.navigationStack.replacePath({ name: route }, false);
  }

  popRoute(fallback: AppRoute): void {
    if (this.navigationStack.getAllPathName().length > 0) {
      this.navigationStack.pop();
      return;
    }
    this.replaceRoute(fallback);
  }

  backAction(route: AppRoute): AppNavigationBackAction {
    return AppRouteContract.backAction(route, this.state.showSidebar);
  }
}
