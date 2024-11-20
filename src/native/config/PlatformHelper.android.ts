import { BaseItemAnimator, RecyclerListViewProps } from "recyclerlistview";
import { ScrollViewProps } from "react-native";

import { BidirectionalScrollView } from "../../BidirectionalScrollView";

const PlatformConfig = {
  defaultDrawDistance: 250,
  // Using rotate instead of scaleY on Android to avoid performance issues. Issue: https://github.com/Shopify/flash-list/issues/751
  invertedTransformStyle: { transform: [{ rotate: "180deg" }] },
  invertedTransformStyleHorizontal: { transform: [{ rotate: "180deg" }] },
};

const getCellContainerPlatformStyles = (
  inverted: boolean,
  parentProps: { x: number; y: number; isHorizontal?: boolean }
): { transform: string; WebkitTransform: string } | undefined => {
  return undefined;
};

const getItemAnimator = (): BaseItemAnimator | undefined => {
  return undefined;
};

const getFooterContainer = (): React.ComponentClass | undefined => {
  return undefined;
};

const getBidirectionalScrollView = (
  experimentalMaintainVisibleContentPosition: boolean | undefined,
  renderScrollComponent:
    | React.FC<ScrollViewProps>
    | React.ComponentType<ScrollViewProps>
    | undefined
) => {
  return experimentalMaintainVisibleContentPosition
    ? (BidirectionalScrollView as unknown as RecyclerListViewProps["externalScrollView"])
    : (renderScrollComponent as unknown as RecyclerListViewProps["externalScrollView"]);
};

const processDecelerationRate = (
  decelerationRate?: "normal" | "fast" | number
) => {
  if (decelerationRate === "normal") {
    return 0.985;
  } else if (decelerationRate === "fast") {
    return 0.9;
  }

  return decelerationRate;
};

export {
  PlatformConfig,
  getCellContainerPlatformStyles,
  getItemAnimator,
  getFooterContainer,
  getBidirectionalScrollView,
  processDecelerationRate,
};
