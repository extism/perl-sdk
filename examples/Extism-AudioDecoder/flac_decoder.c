#define DR_FLAC_IMPLEMENTATION
#define EXTISM_USE_LIBC
#define EXTISM_IMPLEMENTATION
#include "dr_flac.h"
#include "extism-pdk.h"
#include <stdio.h>
#include <stdlib.h>

int32_t EXTISM_EXPORTED_FUNCTION(open_memory) {
  size_t input_size;
  void *input = extism_load_input_dup(&input_size);
  if (!input) {
    return 1;
  }
  drflac *decoder = drflac_open_memory(input, input_size, NULL);
  if (!decoder) {
    return 2;
  }
  extism_output_buf(&decoder, sizeof(decoder));
  // input is intentionally not free'd as it must stay alive as long
  // as the decoder
  return 0;
}

int32_t EXTISM_EXPORTED_FUNCTION(get_metadata) {
  drflac *decoder;
  if (extism_input_length() != sizeof(decoder)) {
    return 1;
  }
  extism_load_input(0, &decoder, sizeof(decoder));
  char buf[128];
  snprintf(buf, sizeof(buf),
           "{\"sample_rate\": %u, \"bit_depth\": %u, \"channels\": %u}",
           decoder->sampleRate, decoder->bitsPerSample, decoder->channels);
  extism_output_buf_from_sz(buf);
  return 0;
}

int32_t EXTISM_EXPORTED_FUNCTION(decode) {
  drflac *decoder;
  if (extism_input_length() != sizeof(decoder)) {
    return 1;
  }
  extism_load_input(0, &decoder, sizeof(decoder));
  void *buf = malloc(decoder->totalPCMFrameCount * decoder->channels * 2);
  if (buf == NULL) {
    return 2;
  }
  uint64_t framesRead =
      drflac_read_pcm_frames_s16(decoder, decoder->totalPCMFrameCount, buf);
  extism_output_buf(buf, framesRead * decoder->channels * 2);
  free(buf);
  return 0;
}
