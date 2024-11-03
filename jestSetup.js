jest.mock("@jeremybarbet/flash-list", () => {
  const ActualFlashList = jest.requireActual("@jeremybarbet/flash-list").FlashList;
  class MockFlashList extends ActualFlashList {
    componentDidMount() {
      super.componentDidMount();
      this.rlvRef?._scrollComponent?._scrollViewRef?.props.onLayout({
        nativeEvent: { layout: { height: 900, width: 400 } },
      });
    }
  }
  return {
    ...jest.requireActual("@jeremybarbet/flash-list"),
    FlashList: MockFlashList,
    AnimatedFlashList: MockFlashList,
  };
});
