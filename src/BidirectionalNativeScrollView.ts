import type { ReactNode } from "react";
import { Platform, requireNativeComponent, ViewStyle } from "react-native";

const LINKING_ERROR =
  `The package 'react-native-flashlist' doesn't seem to be linked. Make sure: \n\n${Platform.select(
    {
      ios: "- You have run 'pod install'\n",
      default: "",
    }
  )}- You rebuilt the app after installing the package\n` +
  `- You are not using Expo managed workflow\n`;

interface BidirectionalNativeScrollViewProps {
  style: ViewStyle;
  children: ReactNode;
}

const BidirectionalNativeScrollView =
  requireNativeComponent<BidirectionalNativeScrollViewProps>(
    "BidirectionalScrollView"
  );

if (BidirectionalNativeScrollView === null) {
  throw new Error(LINKING_ERROR);
}

export { BidirectionalNativeScrollView };
