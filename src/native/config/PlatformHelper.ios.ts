import { ScrollViewProps } from "react-native";
import { BaseItemAnimator, RecyclerListViewProps } from "recyclerlistview";

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
  return renderScrollComponent as unknown as RecyclerListViewProps["externalScrollView"];
};

const processDecelerationRate = (
  decelerationRate?: "normal" | "fast" | number
) => {
  if (decelerationRate === "normal") {
    return 0.998;
  } else if (decelerationRate === "fast") {
    return 0.99;
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
