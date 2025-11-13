import React from 'react'
import '../styles/global.css'
import '../styles/BooksManagement.css'

const BooksManagement = () => {

  const handleRequests = () => {
    alert('تم الضغط على إدارة محتوى طلبات الكتب');
  };

  const handleBooks = () => {
    alert('تم الضغط على إدارة الكتب');
  };

  const handleQuestions = () => {
    alert('تم الضغط على الأسئلة والأجوبة');
  };

  return (
    <div className="books-management">
      <div className="page-header">
        <h1>الإدارة العامة</h1>
      </div>

      <div className="buttons-container">
        <button className="btn-primary" onClick={handleRequests}>إدارة محتوى طلبات الكتب</button>
        <button className="btn-secondary" onClick={handleBooks}>إدارة الكتب</button>
        <button className="btn-tertiary" onClick={handleQuestions}>الأسئلة والأجوبة</button>
      </div>
    </div>
  );
};

export default BooksManagement
