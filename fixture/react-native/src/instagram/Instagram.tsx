import React, { useContext, useState } from "react";
import { StyleSheet, Button, View } from "react-native";
import { BlankAreaEventHandler, FlashList } from "@jeremybarbet/flash-list";
import { useHeaderHeight } from "@react-navigation/elements";

import { DebugContext } from "../Debug";

import { reels as reelsData } from "./data/reels";
import InstagramCell, { height } from "./InstagramCell";
import Reel from "./models/Reel";

export interface InstagramProps {
  instance?: React.RefObject<FlashList<Reel>>;
  blankAreaTracker?: BlankAreaEventHandler;
}

const Instagram = ({ instance, blankAreaTracker }: InstagramProps) => {
  const headerHeight = useHeaderHeight();
  const debugContext = useContext(DebugContext);
  const [reels, setReels] = useState(
    debugContext.emptyListEnabled ? [] : reelsData
  );

  const concatReel = () => {
    setReels((prev) => {
      const reel = reelsData[Math.floor(Math.random() * prev.length)];
      const id = prev.length ? prev[0].id - 1 : 0;

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
        snapToAlignment="start"
        decelerationRate="fast"
        snapToInterval={height - headerHeight}
        estimatedItemSize={height - headerHeight}
        drawDistance={height - headerHeight + 1}
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
