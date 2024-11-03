import { BaseItemAnimator, RecyclerListViewProps } from "recyclerlistview";
import { DefaultJSItemAnimator } from "recyclerlistview/dist/reactnative/platform/reactnative/itemanimators/defaultjsanimator/DefaultJSItemAnimator";
import { Platform, ScrollViewProps } from "react-native";

import { BidirectionalScrollView } from "../../BiDirectionalScrollView";

const PlatformConfig = {
  defaultDrawDistance: 250,
  invertedTransformStyle: { transform: [{ scaleY: -1 }] },
  invertedTransformStyleHorizontal: { transform: [{ scaleX: -1 }] },
};

const getCellContainerPlatformStyles = (
  inverted: boolean,
  parentProps: { x: number; y: number; isHorizontal?: boolean }
): { transform: string; WebkitTransform: string } | undefined => {
  return undefined;
};

const getItemAnimator = (): BaseItemAnimator | undefined => {
  return new DefaultJSItemAnimator();
};

const getFooterContainer = (): React.ComponentClass | undefined => {
  return undefined;
};

const getBidirectionalScrollView = (
  maintainVisibleContentPosition: boolean | undefined,
  renderScrollComponent:
    | React.FC<ScrollViewProps>
    | React.ComponentType<ScrollViewProps>
    | undefined
) => {
  console.log(
    "-maintainVisibleContentPosition",
    maintainVisibleContentPosition
  );

  return maintainVisibleContentPosition && Platform.OS === "android"
    ? (BidirectionalScrollView as unknown as RecyclerListViewProps["externalScrollView"])
    : (renderScrollComponent as unknown as RecyclerListViewProps["externalScrollView"]);
};

export {
  PlatformConfig,
  getCellContainerPlatformStyles,
  getItemAnimator,
  getFooterContainer,
  getBidirectionalScrollView,
};
