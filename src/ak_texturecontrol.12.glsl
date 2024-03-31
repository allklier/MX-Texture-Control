 
uniform float adsk_result_w;
uniform float adsk_result_h;
uniform sampler2D Front;
uniform sampler2D Matte;
uniform sampler2D adsk_results_pass2;
uniform sampler2D adsk_results_pass3;
uniform sampler2D adsk_results_pass5;
uniform sampler2D adsk_results_pass7;
uniform sampler2D adsk_results_pass9;
uniform sampler2D adsk_results_pass11;

uniform float detail_tiny;
uniform float detail_small;
uniform float detail_medium;
uniform float detail_large;
uniform float detail_xlarge;

uniform float mix_lows;
uniform float mix_mids;
uniform float mix_high;

float adsk_getLuminance(in vec3 color);
float adsk_highlights(in float pixel, in float halfPoint);
float adsk_shadows(in float pixel, in float halfPoint);

vec2 res   = vec2(adsk_result_w,adsk_result_h);
vec2 uv    = gl_FragCoord.xy / res.xy;

void main(void) {
  vec4 pixel = texture2D(Front,uv);
  float mixvalue = 0.0;

  // Create HPFs
  vec4 hpf_tiny   = pixel - texture2D(adsk_results_pass3,uv);
  vec4 hpf_small  = texture2D(adsk_results_pass5,uv) - texture2D(adsk_results_pass3,uv);
  vec4 bpf_medium = texture2D(adsk_results_pass7,uv) - texture2D(adsk_results_pass5,uv);
  vec4 bpf_large  = texture2D(adsk_results_pass9,uv) - texture2D(adsk_results_pass7,uv);
  vec4 bpf_xlarge = texture2D(adsk_results_pass11,uv) - texture2D(adsk_results_pass9,uv);
 
  // Determine mix value based on tonality
  float lum = adsk_getLuminance(pixel.rgb);
  mixvalue += mix_lows * adsk_shadows(lum,0.33);
  mixvalue += mix_mids * (1.0 - adsk_shadows(lum,0.33) - adsk_highlights(lum,0.66)); 
  mixvalue += mix_high * adsk_highlights(lum,0.66);
  
  // combine based on weights
  pixel += hpf_tiny * detail_tiny * mixvalue;
  pixel += hpf_small * detail_small * mixvalue;
  pixel += bpf_medium * detail_medium * mixvalue;
  pixel += bpf_large * detail_large * mixvalue;
  pixel += bpf_xlarge * detail_xlarge * mixvalue;

  gl_FragColor = mix(texture2D(Front,uv),pixel,texture2D(Matte,uv).r);
}

