<template>
  <div>
    <div class='row mb-2'>
      <h3 class='col-3 mb-0'>Tags</h3>
      <div class='col-9 d-flex align-items-center'>
        <h5 class='mb-0'>カテゴリ選択：</h5>
        <select class='badge border border-success text-success mr-4' style='font-size: 20px;' name='category_name' id='category_name' v-model='selectedCategory'>
          <option>未選択</option>
          <option v-for='(category, index) in categories'>{{category}}</option>
        </select>
        <h5 class='mb-0'>オプション選択：</h5>
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