RSpec.describe 'tagモデルのテスト' do
  describe 'バリデーションのテスト' do
    let!(:other_tag) { create(:tag) }
    let(:tag) { build(:tag) }

    context 'tagsテーブル' do
      it "有効な投稿内容の場合は保存されるか" do
        expect(tag).to be_valid
      end
    end

    context 'cnameカラム' do
      it "空欄でないこと" do
        tag.name = ''
        expect(tag).to be_invalid
      end
      it "一意性があること" do
        tag.name = other_tag.name
        expect(tag).to be_invalid
      end
    end

  end
end