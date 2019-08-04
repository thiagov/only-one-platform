vec4 effect(vec4 color, Image currentTexture, vec2 texCoords, vec2 screenCoords){
  vec4 sum = vec4(0.0);

  number blurSize = 0.001;
  sum += Texel(currentTexture, vec2(texCoords.x - 4.0*blurSize, texCoords.y)) * 0.05;
  sum += Texel(currentTexture, vec2(texCoords.x - 3.0*blurSize, texCoords.y)) * 0.09;
  sum += Texel(currentTexture, vec2(texCoords.x - 2.0*blurSize, texCoords.y)) * 0.12;
  sum += Texel(currentTexture, vec2(texCoords.x - blurSize, texCoords.y)) * 0.15;
  sum += Texel(currentTexture, vec2(texCoords.x, texCoords.y)) * 0.16;
  sum += Texel(currentTexture, vec2(texCoords.x + blurSize, texCoords.y)) * 0.15;
  sum += Texel(currentTexture, vec2(texCoords.x + 2.0*blurSize, texCoords.y)) * 0.12;
  sum += Texel(currentTexture, vec2(texCoords.x + 3.0*blurSize, texCoords.y)) * 0.09;
  sum += Texel(currentTexture, vec2(texCoords.x + 4.0*blurSize, texCoords.y)) * 0.05;

  return sum;
}
