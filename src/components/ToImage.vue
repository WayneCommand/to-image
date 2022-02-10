<template>
  <div>
    <va-card color="background" class="page-card">
      <div class="row" >
        <div class="flex md12" >
          <div class="item">
            <va-file-upload
                v-model="images"
                dropzone
                file-types=".jpg,.png,.jfif,.webp,"
                type="gallery"
            />
          </div>
        </div>
      </div>
    </va-card>

    <div class="row">
      <div class="flex md3">
        <va-card class="page-card">
          <va-card-title>JPG</va-card-title>
          <va-card-content>
            <va-image
                :src="images"
                style="min-height: 300px"
            >
              <template #loader>
                <va-progress-circle indeterminate />
              </template>
            </va-image>
          </va-card-content>
          <va-card-actions align="stretch" vertical>
            <va-button>Download</va-button>
          </va-card-actions>
        </va-card>
      </div>
      <div class="flex md3">
        <va-card class="page-card">
          <va-card-title>PNG</va-card-title>
          <va-card-content>
            <va-image
                src="https://picsum.photos/400/200"
            />
          </va-card-content>
          <va-card-actions align="stretch" vertical>
            <va-button>Download</va-button>
          </va-card-actions>
        </va-card>
      </div>
      <div class="flex md3">
        <va-card class="page-card">
          <va-card-title>JFIF</va-card-title>
          <va-card-content>
            <va-image
                src="https://picsum.photos/400/200"
            />
          </va-card-content>
          <va-card-actions align="stretch" vertical>
            <va-button>Download</va-button>
          </va-card-actions>
        </va-card>
      </div>
      <div class="flex md3">
        <va-card class="page-card">
          <va-card-title>WEBP</va-card-title>
          <va-card-content>
            <va-image
                src="https://picsum.photos/400/200"
            />
          </va-card-content>
          <va-card-actions align="stretch" vertical>
            <va-button>Download</va-button>
          </va-card-actions>
        </va-card>
      </div>
    </div>


  </div>
</template>

<script>
export default {
  name: "ToImage",
  data () {
    return {
      images:[],
      jpg: {},
      png: {},
      jfif: {},
      webp: {},
    }
  },
  watch: {
    images(data) {
      if (data.length) {
        let uploadFile = data[data.length - 1];
        console.log(uploadFile);
      }
    }
  }
}
</script>

<style scoped>

.page-card {
  padding: 0.75rem;
  margin: 0.25rem;
}

</style>