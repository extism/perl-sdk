#define DR_WAV_IMPLEMENTATION
#define EXTISM_USE_LIBC
#define EXTISM_IMPLEMENTATION
#include "dr_wav.h"
#include "extism-pdk.h"
#include <stdio.h>
#include <stdlib.h>

int32_t EXTISM_EXPORTED_FUNCTION(open_memory) {
  size_t input_size;
  void *input = extism_load_input_dup(&input_size);
  if (!input) {
    return 1;
  }
  drwav *decoder = malloc(sizeof(*decoder));
  if (!decoder) {
    return 2;
  }
  if (!drwav_init_memory(decoder, input, input_size, NULL)) {
    return 3;
  }
  extism_output_buf(&decoder, sizeof(decoder));
  // input is intentionally not freed so it stays alive with the decoder
  return 0;
}

int32_t EXTISM_EXPORTED_FUNCTION(get_metadata) {
  drwav *decoder;
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
  drwav *decoder;
  if (extism_input_length() != sizeof(decoder)) {
    return 1;
  }
  extism_load_input(0, &decoder, sizeof(decoder));
  void *buf = malloc(decoder->totalPCMFrameCount * decoder->channels * 2);
  if (buf == NULL) {
    return 2;
  }
  uint64_t framesRead =
      drwav_read_pcm_frames_s16(decoder, decoder->totalPCMFrameCount, buf);
  extism_output_buf(buf, framesRead * decoder->channels * 2);
  free(buf);
  return 0;
}
