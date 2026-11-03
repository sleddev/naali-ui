#version 460 core

#include <flutter/runtime_effect.glsl>

// One pass of a separable Gaussian whose sigma falls linearly from uSigma at
// uTop to zero at uTop + uHeight. Run twice (horizontal, then vertical).
// Coordinates are physical pixels of the backdrop texture.

uniform vec2 uSize;      // set by the engine: backdrop texture size
uniform float uTop;      // top of the blurred region
uniform float uHeight;   // height of the blurred region
uniform float uSigma;    // sigma at the top edge
uniform float uVertical; // 0 = horizontal pass, 1 = vertical pass
uniform sampler2D uTexture;

out vec4 fragColor;

// Taps per side at full blur. Taps cover ±3 sigma, so weak blur near the
// bottom needs (and uses) far fewer.
const int kMaxTaps = 24;

void main() {
  vec2 p = FlutterFragCoord().xy;
  vec2 uv = p / uSize;
  float t = clamp((p.y - uTop) / uHeight, 0.0, 1.0);
  float sigma = uSigma * (1.0 - t);
  if (sigma < 0.3) {
    fragColor = texture(uTexture, uv);
    return;
  }
  float n = min(float(kMaxTaps), ceil(sigma * 3.0)); // stride >= 1px
  float stride = sigma * 3.0 / n;
  // Once the stride passes a pixel, per-pixel phase jitter (interleaved
  // gradient noise) turns the banding it leaves on hard edges into fine grain.
  float jitter = (fract(52.9829189 * fract(dot(p, vec2(0.06711056, 0.00583715)))) - 0.5) *
                 clamp(stride - 1.0, 0.0, 1.0);
  // Clamp taps to the texture: outside it the sampler returns transparent,
  // which would let the sharp backdrop show through near the screen edges.
  vec2 lo = 0.5 / uSize;
  vec2 hi = 1.0 - lo;
  vec2 dir = (uVertical > 0.5 ? vec2(0.0, 1.0) : vec2(1.0, 0.0)) / uSize;
  float k = -0.5 / (sigma * sigma);
  vec4 sum = vec4(0.0);
  float total = 0.0;
  for (int i = 0; i <= 2 * kMaxTaps; i++) {
    float j = float(i) - n;
    if (j > n) break;
    float x = (j + jitter) * stride;
    float w = exp(k * x * x);
    sum += texture(uTexture, clamp(uv + dir * x, lo, hi)) * w;
    total += w;
  }
  // Normalise by the coverage actually gathered: taps that land on transparent
  // texels (outside the filter's input near screen edges) would otherwise
  // leave the result translucent and let the sharp backdrop ghost through.
  vec4 c = sum / total;
  fragColor = c.a > 0.001 ? vec4(c.rgb / c.a, 1.0) : vec4(0.0);
}
