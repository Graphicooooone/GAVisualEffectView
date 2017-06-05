# GAVisualEffectView
实现低版本直接使用UIVisualEffectView获取模糊效果</br>
在低版本中可直接使用UIVisualEffectView 由GAVisualEffectView实现运行时类注册</br>

# 实现方案
* iOS8以后 直接使用UIVisualEffectView实现模糊效果
* iOS8之前 使用GAVisualEffectView实现模糊 设置可以使用GAVisualEffectScheme属性指定模糊方案
- 当属性为 GAVisualEffectScheme_CoreImage 使用CoreImage实现模糊
- 当属性为 GAVisualEffectScheme_GPUImage 使用GPUImage框架实现模糊 (在项目存在GPUImage的前提下)
- 属性默认为 GAVisualEffectScheme_Auto </br>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;优先级为 GAVisualEffectScheme_CoreImage > GAVisualEffectScheme_GPUImage
