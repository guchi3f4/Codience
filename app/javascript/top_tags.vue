<template>
  <div>
    <div class='d-md-flex '>
      <h4 class='col-md-6 text-line d-sm-flex font-weight-bold font-italic'>人気タグ一覧</h4>
      <div class='col-md-6 d-flex align-items-center'>
        <h5 class='mb-0'>カテゴリ選択：</h5>
        <select class='badge border border-success text-success' style='font-size: 20px;' name='category_name' id='category_name' v-model='selectedCategory'>
          <option>未選択</option>
          <option v-for='(category, index) in categories'>{{category}}</option>
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
      };
    },

    watch: {
      selectedCategory: function() {
        setTimeout(() => {
          document.getElementById('search-btn').click();
        }, 1);
      },
    }
  };
</script>