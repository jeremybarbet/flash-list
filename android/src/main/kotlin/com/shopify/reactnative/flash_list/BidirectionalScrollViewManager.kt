package com.shopify.reactnative.flash_list

import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.views.scroll.ReactScrollView
import com.facebook.react.views.scroll.ReactScrollViewManager

@ReactModule(name = AutoLayoutViewManager.REACT_CLASS)
class BidirectionalScrollViewManager : ReactScrollViewManager() {
  companion object {
    const val REACT_CLASS = "BidirectionalScrollView"
  }

  override fun getName(): String {
    return REACT_CLASS
  }

  override fun createViewInstance(context: ThemedReactContext): ReactScrollView {
    return BidirectionalScrollView(context)
  }
}