<template>
  <div>
    <div class='row mb-2'>
      <h3 class='col-3 mb-0'>Tag検索</h3>
      <div class='col-9 d-flex align-items-center'>
        <h5 class='mb-0'>カテゴリ選択：</h5>
        <select class='badge border border-success text-success' style="font-size: 20px;" name="category_name" id="category_name" v-model='selectedCategory'>
          <option>未選択</option>
          <option v-for='(category, index) in categories'>{{category}}</option>
        </select>
      </div>
    </div>

    <input type="hidden" id="tag-names" class="form-control" v-model="tags" name="content">
    <div class="d-flex flex-wrap align-items-center border rounded py-2 px-1" @click='inputField'>
      <div class="badge badge-primary badge-pill mr-1" style="font-size: 100%;" v-for="tag in tags">
        {{tag}}<span class="pl-1" type="button"v-on:click="delTag(tag)">×</span>
      </div>
      <input id="search-field" class="border-0" style="outline: 0" type="text" placeholder="複数選択できます" v-model="newTag" v-on:keydown.enter="setTag"
      @input='onInput' autocomplete="off">
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
    <p>{{error}}</p>
  </div>
</template>

<script>
  import axios from 'axios'

  export default {
    data () {
        return {
          newTag: '',
          categories: JSON.parse(document.getElementById('category-names').dataset.json),
          tags: [],
          allTags: [],
          open: false,
          error: '',
          selectedCategory: '未選択'
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
          return this.error = 'このタグは存在しません',
          this.open = false;
        }
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
        document.getElementById("search-field").focus();
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
      }
    },

    watch: {
      selectedCategory: function() {
        setTimeout(() => {
          document.getElementById("search-btn").click();
        }, 1)
        document.getElementById("search-field").focus()
      },

      tags: function() {
        setTimeout(() => {
          document.getElementById("search-btn").click();
        }, 1)
        document.getElementById("search-field").focus()
      }
    }
  }
</script>