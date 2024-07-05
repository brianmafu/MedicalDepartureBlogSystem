import databasePool  from "../config/database";
import { RowDataPacket } from 'mysql2/promise';
import { OkPacket } from 'mysql2';

// Blog Interface
export interface Blog{
  id?: number;
  user_id: number;
  title: string;
  content: string;
  created_at?: Date;
  updated_at?: Date;
}

interface BlogRow extends Blog, RowDataPacket {}  // Separate interface for RowDataPacket
// Create a new blog
export const createBlog = async (blog: Omit<Blog, 'id' | 'created_at' | 'updated_at'>) => {
  const { title, content, user_id } = blog;
  const [result] = await databasePool.query<OkPacket>(
    'INSERT INTO Blogs (user_id, title, content) VALUES (?, ?, ?)',
    [user_id, title, content]
  );
  return { id: result.insertId, ...blog };
};

// get all blogs
export const getBlogs = async() => {
	const result = await databasePool.query('SELECT * FROM Blogs');
	return result[0];
}

// get blog by id
export const getBlogById = async(id: number) => {
	const result = await databasePool.query('SELECT * FROM Blogs WHERE id = ?', [id]);
	return result[0];
}

// update blog by id
export const updateBlogById = async(id: number, blog: Blog) => {
	const result = await databasePool.query('UPDATE Blogs SET title = ?, content = ? WHERE id = ?', [blog.title, blog.content, id]);
	return result[0];
}

// delete blog by id
export const deleteBlogById = async(id: number) => {
	const result = await databasePool.query('DELETE FROM Blogs WHERE id = ?', [id]);
	return result[0];
}