import React from "react";
import { Text, Image, Dimensions, StyleSheet, View } from "react-native";
import { useHeaderHeight } from "@react-navigation/elements";

import Reel from "./models/Reel";

export interface InstagramCellProps {
  reel: Reel;
}

export const { width, height } = Dimensions.get("window");

const InstagramCell = ({ reel }: InstagramCellProps) => {
  const headerHeight = useHeaderHeight();

  return (
    <View style={{ height: height - headerHeight, overflow: "hidden" }}>
      <View style={styles.meta}>
        <Text style={styles.name}>{reel.name}</Text>
        <Text style={styles.description}>{reel.description}</Text>
      </View>

      <Image
        style={styles.image}
        source={{ uri: reel.image }}
        resizeMode="cover"
      />
    </View>
  );
};

const styles = StyleSheet.create({
  meta: {
    position: "absolute",
    right: 0,
    bottom: 0,
    left: 0,
    zIndex: 5,

    padding: 20,
    paddingBottom: 30,

    backgroundColor: "rgba(0,0,0,0.25)",
  },

  name: {
    marginBottom: 10,

    fontWeight: "bold",
    fontSize: 20,

    color: "white",
  },

  description: {
    fontSize: 16,

    color: "white",
  },

  image: {
    zIndex: 1,

    width,
    height,
  },
});

export default InstagramCell;
