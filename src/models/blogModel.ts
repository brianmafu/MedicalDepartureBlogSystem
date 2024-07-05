import { databasePool } from "../config/database.ts";

// Blog Interface
interface Blog {
  id: number;
  title: string;
  content: string;
}

// Create a new blog
export const createBlog = async(blog: Blog) => {
	const result = await databasePool.query(
	'INSERT INTO blogs (title, content) VALUES (?, ?)',
	[blog.title, blog.content]
  );
  return result[0];
}

// get all blogs
export const getBlogs = async() => {
	const result = await databasePool.query('SELECT * FROM blogs');
	return result[0];
}

// get blog by id
export const getBlogById = async(id: number) => {
	const result = await databasePool.query('SELECT * FROM blogs WHERE id = ?', [id]);
	return result[0];
}

// update blog by id
export const updateBlogById = async(id: number, blog: Blog) => {
	const result = await databasePool.query('UPDATE blogs SET title = ?, content = ? WHERE id = ?', [blog.title, blog.content, id]);
	return result[0];
}

// delete blog by id
export const deleteBlogById = async(id: number) => {
	const result = await databasePool.query('DELETE FROM blogs WHERE id = ?', [id]);
	return result[0];
}