<template>
  <div>
    <!--<div class="d-flex flex-wrap align-items-center border rounded py-2 px-1">-->
    <!--  <div class="badge badge-primary badge-pill mr-1" style="font-size: 100%;" v-for="topTag in topTags">-->
    <!--    {{topTag}}<span class="pl-1" type="button" v-on:click="delTopTag(topTag)">×</span>-->
    <!--  </div>-->
    <!--  <input id="top-field" class="border-0" style="outline: 0" type="text" autocomplete="off" placeholder="一つ選択できます"-->
    <!--    v-model='newTopTag' v-on:keydown.enter="setTopTag"-->
    <!--  >-->
    <!--</div>-->

    <input type="hidden" id="tag-name" class="form-control" v-model="tags" name="content">
    <div class="d-flex flex-wrap align-items-center border rounded py-2 px-1">
      <div class="badge badge-primary badge-pill mr-1" style="font-size: 100%;" v-for="tag in tags">
        {{tag}}<span class="pl-1" type="button"v-on:click="delTag(tag)">×</span>
      </div>
      <input id="field1" class="border-0" style="outline: 0" type="text" placeholder="複数選択できます" v-model="newTag" v-on:keydown.enter="setTag"
      @input='onInput' autocomplete="off">
    </div>

    <!--補完部分の表示-->
    <div v-if="allTags.length && open">
      <div class='d-flex mt-2 p-2 border '>
        <div v-for="(tag2, index) in allTags" id='select-tags' class ="btn btn-primary rounded-pill mr-1 py-0"
          @click='selectTag(index)' v-bind:key="tag2.index" style="cursor: pointer">
          {{tag2}}
        </div>
      </div>
    </div>
    <p>{{error}}</p>
  </div>
</template>

<script>
  import axios from 'axios'

  export default {
    data () {
        return {
          // newTopTag: '',
          newTag: '',
          // topTags: [],
          tags: [],
          allTags: [],
          open: false,
          error: ''
        }
    },

    methods: {
      // setTopTag: function (event) {
      //   if (event.keyCode !== 13 || this.newTopTag == '') return
      //   let topTag = this.newTopTag;
      //   this.topTags.push(topTag);
      //   this.newTopTag = '';
      //   setTimeout(() => {
      //     this.topOpen = false;
      //   }, 300)
      // },
      // delTopTag: function(topTag) {
      //   this.topTags.splice(this.topTags.indexOf(topTag), 1);
      // },

　　　// エンターキー押下時
      setTag: function (event) {
        if (event.keyCode !== 13 || this.newTag === '') return
        if (this.allTags === '' || this.allTags.indexOf(this.newTag) === -1) {
          return this.error = 'このタグは存在しません'
        }
        if (this.tags.indexOf(this.newTag) !== -1) {
          return this.error = 'このタグはすでに入力済みです',
          setTimeout(() => {
            this.open = false;
          }, 300)
        }
        let tag = this.newTag;
        this.tags.push(tag);
        this.newTag = '';
        setTimeout(() => {
          this.open = false;
        }, 300)
      },
      delTag: function(tag) {
        this.tags.splice(this.tags.indexOf(tag), 1);
      },

      // 補完情報の取得
      onInput({target}) {
        this.newTag = target.value
        if (this.error.length) {
          this.error = ''
        }
        if (this.newTag != '') {
          axios.get("/api/articles", {
            params: { keyword: this.newTag }
          })
          .then(response => {
            this.allTags = response.data;
            if (this.allTags) {
              this.open = true;
            }
          })
        }
        if (this.newTag == '') {
          setTimeout(() => {
            this.open = false;
          }, 200)
        }
      },

      // 補完項目の選択
      selectTag(index) {
        setTimeout(() => {
          this.open = false;
        }, 300)
        if (this.tags.indexOf(this.allTags[index]) !== -1) {
          return this.error = 'このタグはすでに入力済みです'
        }
        this.tags.push(this.allTags[index]);
        this.newTag = '';
        document.getElementById("field1").focus()
      }
    },

    watch: {
      tags: function() {
        setTimeout(function() {
          document.getElementById("search-btn").click();
        }, 1)
        document.getElementById("field1").focus()
      }
    }
  }
</script>