
uniform float adsk_result_w;
uniform float adsk_result_h;
uniform sampler2D Front;
uniform sampler2D Matte;

vec2 res   = vec2(adsk_result_w,adsk_result_h);
vec2 uv    = gl_FragCoord.xy / res.xy;

void main(void) {
  gl_FragColor = vec4(texture2D(Front,uv).rgb,texture2D(Matte,uv).r);
}

