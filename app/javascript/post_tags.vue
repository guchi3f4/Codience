<template>
  <div class='form-group'>
    <div>
      <label for='field' class='font-weight-bold'>Tag</label>
      <input type="hidden" id="tag-names" class="form-control" v-model="tags" name="tag_names">
      <div class="d-flex flex-wrap align-items-center border rounded py-2 px-1" @click='inputField'>
        <div class="badge badge-primary badge-pill mr-1" style="font-size: 100%;" v-for="tag in tags">
          {{tag}}<span class="pl-1" type="button" v-on:click="delTag(tag)">×</span>
        </div>
        <input id="field" class="border-0" style="outline: 0" type="text" placeholder="複数選択できます" v-model="newTag" v-on:keydown.enter="setTag"
        @input='onInput' autocomplete="off">
      </div>
    </div>
    <!--補完部分の表示-->
    <div v-if="allTags.length && open">
      <div class='d-flex flex-wrap mt-2 p-2 border'>
        <div v-for="(tag2, index) in allTags" id='select-tags' class ="btn btn-primary rounded-pill mr-1 mb-1 py-0"
          @click='selectTag(index)' v-bind:key="tag2.index" style="cursor: pointer">
          {{tag2}}
        </div>
      </div>
    </div>
    <span>{{error}}</span>
  </div>
</template>

<script>
  import axios from 'axios'

  export default {
    data () {
      return {
        newTag: '',
        tags: [],
        allTags: [],
        open: false,
        error: '',
      }
    },

    created: function() {
      if (document.getElementById("json_tag_names") != null) {
        this.tags = JSON.parse(document.getElementById('json_tag_names').dataset.json);
      }
    },

    methods: {
      // エンターキー押下時
      setTag: function (event) {
        if (event.keyCode !== 13 || this.newTag === '') return
        if (this.tags.indexOf(this.newTag) !== -1) {
          return this.error = 'このタグはすでに入力済みです',
          this.open = false;
        }
        let tag = this.newTag;
        this.tags.push(tag);
        this.newTag = '';
        this.open = false;
      },
      delTag: function(tag) {
        this.tags.splice(this.tags.indexOf(tag), 1);
      },

      inputField: function() {
        document.getElementById("field").focus();
      },

      // 補完情報の取得
      onInput({target}) {
        this.newTag = target.value
        if (this.error.length) {
          this.error = ''
        }
        if (this.newTag != '') {
          this.open = true;
          axios.get("/api/articles", {
            params: { keyword: this.newTag }
          })
          .then(response => {
            this.allTags = response.data;
            if (this.allTags == []) {
              this.open = false;
            }
          });
        }
        if (this.newTag == '') {
          this.open = false;
        }
      },

      // 補完項目の選択
      selectTag(index) {
        this.open = false;
        if (this.tags.indexOf(this.allTags[index]) !== -1) {
          return this.error = 'このタグはすでに入力済みです'
        }
        this.tags.push(this.allTags[index]);
        this.newTag = '';
        document.getElementById("field").focus();
      }
    },
  }
</script>