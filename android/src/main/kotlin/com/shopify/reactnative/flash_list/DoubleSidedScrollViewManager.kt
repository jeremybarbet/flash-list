package com.shopify.reactnative.flash_list

import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.views.scroll.ReactScrollView
import com.facebook.react.views.scroll.ReactScrollViewManager

@ReactModule(name = DoubleSidedScrollViewManager.REACT_CLASS)
class DoubleSidedScrollViewManager : ReactScrollViewManager() {
  companion object {
    const val REACT_CLASS = "DoubleSidedScrollView"
  }

  override fun getName(): String {
    return REACT_CLASS
  }

  override fun createViewInstance(context: ThemedReactContext): ReactScrollView {
    return DoubleSidedScrollView(context)
  }
}
