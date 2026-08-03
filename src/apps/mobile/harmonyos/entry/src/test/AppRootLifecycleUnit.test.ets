import { describe, expect, it } from '@ohos/hypium';
import { AppRootHostPort } from '../main/ets/pages/host/AppRootHostAdapter';
import { AppRootRuntime } from '../main/ets/pages/state/AppRootRuntime';

class FakeAppRootHost implements AppRootHostPort {
  attach(_context: Context, _uiContext: UIContext): void {
  }

  context(): Context {
    return {} as Context;
  }

  animate(_duration: number, callback: () => void): void {
    callback();
  }

  showToast(_message: string, _duration: number): boolean {
    return false;
  }
}

class TestAppRootRuntime extends AppRootRuntime {
  stopGeneralChatStreamCalls: number = 0;

  constructor() {
    super(new FakeAppRootHost());
  }

  stopGeneralChatStream(cancelled: boolean, finalStatus: string = 'cancelled'): void {
    this.stopGeneralChatStreamCalls += 1;
    super.stopGeneralChatStream(cancelled, finalStatus);
  }
}

export default function appRootLifecycleUnitTest() {
  describe('AppRootRuntime page hide lifecycle', () => {
    it('keeps backgrounded general chat running on page hide', 0, () => {
      const runtime = new TestAppRootRuntime();

      runtime.onPageHide();

      expect(runtime.stopGeneralChatStreamCalls).assertEqual(0);
    });

    it('still performs general chat cleanup when the app truly disappears', 0, () => {
      const runtime = new TestAppRootRuntime();

      runtime.aboutToDisappear();

      expect(runtime.stopGeneralChatStreamCalls).assertEqual(1);
    });
  });
}
