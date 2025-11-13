import React, { useState } from 'react'
import DataTable from '../components/common/DataTable'
import '../styles/global.css'
import '../styles/BooksManagement.css'

const BooksManagement = () => {
  const [activeSection, setActiveSection] = useState(null);
  const [books, setBooks] = useState([]);
  const [loading, setLoading] = useState(false);

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

  const handleRequests = () => {
    setActiveSection('requests');
  };

  const handleBooks = () => {
    setActiveSection('books');
  };

  const handleQuestions = () => {
    setActiveSection('questions');
  };

  return (
    <div className="books-management">
      <div className="page-header">
        <h1>الإدارة العامة</h1>
      </div>

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

      {/* عرض جدول إدارة الكتب فقط */}
      {activeSection === 'books' && (
        <div className="books-section">
          <h2>قسم إدارة الكتب</h2>
          <DataTable
            columns={bookColumns}
            data={books}
            loading={loading}
          />
        </div>
      )}
    </div>
  );
};

export default BooksManagement
