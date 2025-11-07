// src/components/common/DataTable.jsx
/*import React from 'react'
import './DataTable.css'

const DataTable = ({ 
  title, 
  columns, 
  data = [], 
  onAdd, 
  onEdit, 
  onDelete, 
  emptyMessage = "لا توجد بيانات متاحة" 
}) => {
  
  // بيانات تجريبية لعرض الزراء عندما تكون البيانات فارغة
  const displayData = data && data.length > 0 ? data : [{}];

  return (
    <div className="table-wrapper">
      <div className="table-header">
        <h3 className="table-title">{title}</h3>
        {onAdd && (
          <button className="add-btn" onClick={onAdd}>
            ➕ إضافة جديد
          </button>
        )}
      </div>
      
      <div className="table-container">
        <table className="data-table">
         
          <thead>
            <tr>
              {columns.map(col => (
                <th key={col.key}>{col.label}</th>
              ))}
            </tr>
          </thead>
          
          <tbody>
            {!data || data.length === 0 ? (
              // صف تجريبي لعرض الزراء عندما لا توجد بيانات
              <tr className="table-row">
                {columns.map(col => (
                  <td key={col.key} className="table-cell">
                    {col.key === 'actions' ? (
                      <div className="actions-buttons">
                        {onEdit && (
                          <button 
                            className="edit-btn"
                            onClick={() => onEdit({})}
                            disabled
                          >
                            ✏️ تعديل
                          </button>
                        )}
                        {onDelete && (
                          <button 
                            className="delete-btn"
                            onClick={() => onDelete({})}
                            disabled
                          >
                            🗑️ حذف
                          </button>
                        )}
                      </div>
                    ) : (
                      '-'
                    )}
                  </td>
                ))}
              </tr>
            ) : (
              // البيانات الفعلية
              data.map((row, index) => (
                <tr key={index} className="table-row">
                  {columns.map(col => (
                    <td key={col.key} className="table-cell">
                      {col.key === 'actions' ? (
                        <div className="actions-buttons">
                          {onEdit && (
                            <button 
                              className="edit-btn"
                              onClick={() => onEdit(row)}
                            >
                              ✏️ تعديل
                            </button>
                          )}
                          {onDelete && (
                            <button 
                              className="delete-btn"
                              onClick={() => onDelete(row)}
                            >
                              🗑️ حذف
                            </button>
                          )}
                        </div>
                      ) : (
                        row[col.key] || '-'
                      )}
                    </td>
                  ))}
                </tr>
              ))
            )}
            
           
            {(!data || data.length === 0) && (
              <tr>
                <td colSpan={columns.length} className="empty-message-cell">
                  {emptyMessage}
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default DataTable

*/

import React from 'react'
import './DataTable.css'

const DataTable = ({ 
  columns, 
  data, 
  loading, 
  onEdit, 
  onDelete, 
  onView,
  actions = ['edit', 'delete'] // تحديد الأافعال المتاحة
}) => {
  if (loading) {
    return <div className="loading">جاري التحميل...</div>;
  }

  return (
    <div className="data-table-container">
      <table className="data-table">
        <thead>
          <tr>
            {columns.map((column) => (
              <th key={column.key}>{column.title}</th>
            ))}
            {(actions.includes('edit') || actions.includes('delete') || actions.includes('view')) && (
              <th>الإجراءات</th>
            )}
          </tr>
        </thead>
        <tbody>
          {data && data.length > 0 ? (
            data.map((item, index) => (
              <tr key={item.id || index}>
                {columns.map((column) => (
                  <td key={column.key}>
                    {column.render ? column.render(item[column.key], item) : item[column.key]}
                  </td>
                ))}
                <td className="actions-cell">
                  {actions.includes('view') && onView && (
                    <button 
                      className="btn-view"
                      onClick={() => onView(item)}
                      title="عرض"
                    >
                      👁️
                    </button>
                  )}
                  {actions.includes('edit') && onEdit && (
                    <button 
                      className="btn-edit"
                      onClick={() => onEdit(item)}
                      title="تعديل"
                    >
                      ✏️
                    </button>
                  )}
                  {actions.includes('delete') && onDelete && (
                    <button 
                      className="btn-delete"
                      onClick={() => onDelete(item)}
                      title="حذف"
                    >
                      🗑️
                    </button>
                  )}
                </td>
              </tr>
            ))
          ) : (
            <tr>
              <td colSpan={columns.length + 1} className="no-data">
                لا توجد بيانات
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
};

export default DataTable