import React, { useState } from 'react'
import DataTable from '../components/common/DataTable'
import Modal from '../components/common/Modal'
import '../styles/global.css'
import '../styles/BooksManagement.css'

const BooksManagement = () => {
  const [activeSection, setActiveSection] = useState(null);
  const [books, setBooks] = useState([]);
  const [loading, setLoading] = useState(false);

  // حالة المودال
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingBook, setEditingBook] = useState(null);
  const [formData, setFormData] = useState({
    author: '',
    title: '',
    description: '',
    price: '',
    is_free: 0,
    book_type: '',
    discount_rate: '',
    sectionid: ''
  });

  // أعمدة جدول إدارة الكتب فقط
  const bookColumns = [
    { key: 'id', title: 'ID' },
    { key: 'author', title: 'المؤلف' },
    { key: 'title', title: 'عنوان الكتاب' },
    { key: 'description', title: 'الوصف' },
    { key: 'price', title: 'السعر' },
    { 
      key: 'is_free', 
      title: 'مجاني؟',
      render: (value) => (value === 1 ? 'نعم' : 'لا')
    },
    { key: 'book_type', title: 'نوع الكتاب' },
    { key: 'discount_rate', title: 'نسبة الخصم' },
    { key: 'number_of_likes', title: 'عدد الإعجابات' },
    { key: 'sectionid', title: 'القسم' }
  ];

  const handleRequests = () => setActiveSection('requests');
  const handleBooks = () => setActiveSection('books');
  const handleQuestions = () => setActiveSection('questions');

  // فتح مودال إضافة كتاب جديد
  const handleAddBook = () => {
    setEditingBook(null);
    setFormData({
      author: '',
      title: '',
      description: '',
      price: '',
      is_free: 0,
      book_type: '',
      discount_rate: '',
      sectionid: ''
    });
    setIsModalOpen(true);
  };

  // فتح مودال تعديل كتاب
  const handleEditBook = (book) => {
    setEditingBook(book);
    setFormData({
      author: book.author || '',
      title: book.title || '',
      description: book.description || '',
      price: book.price || '',
      is_free: book.is_free || 0,
      book_type: book.book_type || '',
      discount_rate: book.discount_rate || '',
      sectionid: book.sectionid || ''
    });
    setIsModalOpen(true);
  };

  // حفظ بيانات الكتاب (إضافة أو تعديل)
  const handleSaveBook = () => {
    if (!formData.author || !formData.title || !formData.description || !formData.price) {
      alert('يرجى ملء جميع الحقول المطلوبة');
      return;
    }

    if (editingBook) {
      console.log('تعديل الكتاب:', { id: editingBook.id, ...formData });
      alert('تم تعديل بيانات الكتاب (محاكاة)');
    } else {
      console.log('إضافة كتاب جديد:', formData);
      alert('تم إضافة الكتاب الجديد (محاكاة)');
    }

    setIsModalOpen(false);
    setEditingBook(null);
  };

  return (
    <div className="books-management">
      <div className="page-header">
        <h1>الإدارة العامة</h1>
      </div>

      {/* الأزرار الرئيسية */}
      <div className="buttons-container">
        <button
          className={`btn ${activeSection === 'requests' ? 'btn-primary' : 'btn-outline'}`}
          onClick={handleRequests}
        >
          إدارة محتوى طلبات الكتب
        </button>

        <button
          className={`btn ${activeSection === 'books' ? 'btn-primary' : 'btn-outline'}`}
          onClick={handleBooks}
        >
          إدارة الكتب
        </button>

        <button
          className={`btn ${activeSection === 'questions' ? 'btn-primary' : 'btn-outline'}`}
          onClick={handleQuestions}
        >
          الأسئلة والأجوبة
        </button>
      </div>

      {/* قسم إدارة الكتب */}
      {activeSection === 'books' && (
        <div className="books-section">
          <div className="section-header">
            <h2>قسم إدارة الكتب</h2>
            <button className="btn-primary" onClick={handleAddBook}>
              + إضافة كتاب جديد
            </button>
          </div>

          <DataTable
            columns={bookColumns}
            data={books}
            loading={loading}
            onEdit={handleEditBook} // يفتح الفورم لتعديل الكتاب
          />
        </div>
      )}

      {/* مودال إضافة / تعديل كتاب */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => { setIsModalOpen(false); setEditingBook(null); }}
        title={editingBook ? "تعديل كتاب" : "إضافة كتاب جديد"}
      >
        <div className="book-form">
          <div className="form-group">
            <label>المؤلف *</label>
            <input
              type="text"
              value={formData.author}
              onChange={(e) => setFormData({ ...formData, author: e.target.value })}
              required
            />
          </div>

          <div className="form-group">
            <label>عنوان الكتاب *</label>
            <input
              type="text"
              value={formData.title}
              onChange={(e) => setFormData({ ...formData, title: e.target.value })}
              required
            />
          </div>

          <div className="form-group">
            <label>الوصف *</label>
            <textarea
              value={formData.description}
              onChange={(e) => setFormData({ ...formData, description: e.target.value })}
              required
            ></textarea>
          </div>

          <div className="form-group">
            <label>السعر *</label>
            <input
              type="number"
              value={formData.price}
              onChange={(e) => setFormData({ ...formData, price: e.target.value })}
              min="0"
              required
            />
          </div>

          <div className="form-group">
            <label>هل الكتاب مجاني؟</label>
            <select
              value={formData.is_free}
              onChange={(e) => setFormData({ ...formData, is_free: parseInt(e.target.value) })}
            >
              <option value={0}>لا</option>
              <option value={1}>نعم</option>
            </select>
          </div>

          <div className="form-group">
            <label>نوع الكتاب</label>
            <input
              type="number"
              value={formData.book_type}
              onChange={(e) => setFormData({ ...formData, book_type: e.target.value })}
            />
          </div>

          <div className="form-group">
            <label>نسبة الخصم (%)</label>
            <input
              type="number"
              value={formData.discount_rate}
              onChange={(e) => setFormData({ ...formData, discount_rate: e.target.value })}
              min="0"
              max="100"
            />
          </div>

          <div className="form-group">
            <label>رقم القسم (Section ID)</label>
            <input
              type="number"
              value={formData.sectionid}
              onChange={(e) => setFormData({ ...formData, sectionid: e.target.value })}
            />
          </div>

          <div className="form-actions">
            <button className="btn-secondary" onClick={() => { setIsModalOpen(false); setEditingBook(null); }}>إلغاء</button>
            <button className="btn-primary" onClick={handleSaveBook}>حفظ</button>
          </div>
        </div>
      </Modal>
    </div>
  );
};

export default BooksManagement
