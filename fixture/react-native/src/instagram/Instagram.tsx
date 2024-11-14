import React, { useState } from "react";
import { StyleSheet, Button, View } from "react-native";
import { BlankAreaEventHandler, FlashList } from "@jeremybarbet/flash-list";
import { useHeaderHeight } from "@react-navigation/elements";

import { reels as reelsData } from "./data/reels";
import InstagramCell, { height } from "./InstagramCell";
import Reel from "./models/Reel";

export interface InstagramProps {
  instance?: React.RefObject<FlashList<Reel>>;
  blankAreaTracker?: BlankAreaEventHandler;
  CellRendererComponent?: React.ComponentType<any>;
}

const Instagram = ({
  instance,
  blankAreaTracker,
  CellRendererComponent,
}: InstagramProps) => {
  const headerHeight = useHeaderHeight();
  const [reels, setReels] = useState(reelsData);

  const concatReel = () => {
    setReels((prev) => {
      const reel = prev[Math.floor(Math.random() * prev.length)];
      const id = prev[0].id - 1;

      return [
        {
          ...reel,
          id,
        },
      ].concat(prev);
    });
  };

  return (
    <>
      <View style={styles.button}>
        <Button
          onPress={concatReel}
          title="CONCAT_REEL"
          color="white"
          testID="concat-reel"
        />
      </View>

      <FlashList
        ref={instance}
        onBlankArea={blankAreaTracker}
        testID="FlashList"
        keyExtractor={(item) => String(item.id)}
        renderItem={({ item }) => <InstagramCell reel={item} />}
        CellRendererComponent={CellRendererComponent}
        snapToAlignment="start"
        decelerationRate="fast"
        snapToInterval={height - headerHeight}
        estimatedItemSize={height - headerHeight}
        data={reels}
        experimentalMaintainVisibleContentPosition
      />
    </>
  );
};

const styles = StyleSheet.create({
  button: {
    position: "absolute",
    top: 20,
    left: "50%",
    width: 150,
    zIndex: 10,
    backgroundColor: "black",
    transform: [{ translateX: -75 }],
  },
});

export default Instagram;
