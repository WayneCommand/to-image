<template>
  <div>
    <va-card color="background" class="page-card">
      <div class="row" >
        <div class="flex md12" >
          <div class="item">
            <va-file-upload
                v-model="image"
                dropzone
                file-types=".jpg,.png,.jfif,.webp,.heic,.heif,.avif,"
                type="single"
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
                :src="jpg"
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
                :src="png"
            />
          </va-card-content>
          <va-card-actions align="stretch" vertical>
            <va-button>Download</va-button>
          </va-card-actions>
        </va-card>
      </div>
      <div class="flex md3">
        <va-card class="page-card">
          <va-card-title>HEIF(HEIC)</va-card-title>
          <va-card-content>
            <va-image
                :src="jpg"
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
                :src="webp"
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
const axios = require('axios').default;
export default {
  name: "ToImage",
  data() {
    return {
      image: [],
      jpg: '',
      png: '',
      heif: '',
      webp: '',

    }
  },
  methods: {
    reqImgByFormat(uploadFile, format, setVal) {
      let fd = new FormData()
      fd.append('image', uploadFile);
      const config = {
        headers: {
          'content-type': 'multipart/form-data'
        },
        responseType: 'blob'
      }
      axios.post(`/api/image/${format}`, fd, config)
          .then(resp => {
            setVal(window.URL.createObjectURL(resp.data));
          });
    }
  },
  watch: {
    image(data) {

      if (data.length) {
        let uploadFile = data[data.length - 1];
        this.reqImgByFormat(uploadFile, 'jpg', blob => this.jpg = blob);
        this.reqImgByFormat(uploadFile, 'png', blog => this.png = blog);
        // this.reqImgByFormat(uploadFile, 'avif', blog => this.heif = blog);
        this.reqImgByFormat(uploadFile, 'webp', blog => this.webp = blog);
      }
    }
  }
};
</script>

<style scoped>

.page-card {
  padding: 0.75rem;
  margin: 0.25rem;
}

</style>