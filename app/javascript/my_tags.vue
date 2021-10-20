<template>
  <div>
    <div class='d-flex text-center'>
      <div class='d-md-flex col-6 align-items-center justify-content-center'>
        <h5 class='mb-md-0 text-nowrap'>カテゴリ選択：</h5>
        <select class='badge border border-success text-success mr-4' style='font-size: 20px;' name='category_name' id='category_name' v-model='selectedCategory'>
          <option>未選択</option>
          <option v-for='(category, index) in categories'>{{category}}</option>
        </select>
      </div>
      <div class='d-md-flex col-6 align-items-center justify-content-center'>
        <h5 class='mb-md-0 text-nowrap'>オプション選択：</h5>
        <select class='badge border border-success text-success' style='font-size: 20px;' name='option' id='option' v-model='selectedOption'>
          <option>ブックマーク</option>
          <option>投稿</option>
        </select>
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    data () {
      return {
        categories: JSON.parse(document.getElementById('category-names').dataset.json),
        selectedCategory: '未選択',
        selectedOption: 'ブックマーク'
      };
    },

    watch: {
      selectedCategory: function() {
        setTimeout(() => {
          document.getElementById('search-btn').click();
        }, 1);
      },

      selectedOption: function() {
        setTimeout(() => {
          document.getElementById('search-btn').click();
        }, 1);
      }
    }
  };
</script>