extern number timing;
extern number maxTiming;

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
  vec4 pixel = Texel(texture, texture_coords );//This is the current pixel color
  number average = (pixel.r*color.r+pixel.b*color.b+pixel.g*color.g)/3.0;
  number effectness = timing*1000/maxTiming;
  if (effectness > 1) { effectness=1; }
  pixel.r = pixel.r*color.r-(pixel.r*color.r-average)*effectness;
  pixel.g = pixel.g*color.g-(pixel.g*color.g-average)*effectness;
  pixel.b = pixel.b*color.b-(pixel.b*color.b-average)*effectness;
  pixel.a = pixel.a*color.a;
  return pixel;
}