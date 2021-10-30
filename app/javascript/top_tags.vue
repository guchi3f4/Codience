<template>
  <div>
    <div class='d-sm-flex'>
      <h4 class='text-line col-md-6 d-sm-flex font-weight-bold text-center font-italic'>人気タグ一覧</h4>
      <div class='col-md-6 d-flex align-items-center justify-content-center'>
        <h5 class='mb-0'>カテゴリ選択：</h5>
        <select class='badge border border-success text-success bg-white' style='font-size: 20px;' name='category_name' id='category_name' v-model='selectedCategory'>
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

    created: function() {
      window.onpageshow = function(event) {
        if ( event.persisted || window.performance && window.performance.navigation.type == 2 ) {
          document.getElementById('category_name').value = '未選択';
        }
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