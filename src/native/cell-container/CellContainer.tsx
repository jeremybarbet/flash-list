import React from "react";
import { View, ViewProps } from "react-native";

export interface CellContainerProps extends ViewProps {
  index: number;
  stableId: string;
}

const CellContainer = React.forwardRef(
  (props: CellContainerProps, ref: any) => {
    return <View ref={ref} {...props} />;
  }
);

CellContainer.displayName = "CellContainer";

export default CellContainer;
