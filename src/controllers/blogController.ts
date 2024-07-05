// Blog Controller
import { Request, Response } from 'express';
import { createBlog, getBlogs, getBlogById, updateBlogById, deleteBlogById } from '../models/blogModel.ts';

// create Blog
export const CreateBlog = async (req: Request, res: Response) => {
  const { title, content } = req.body;
  const blog = {
	title,
	content
  }
  try {
	const result = await createBlog(blog);
	res.status(201).json({ message: 'Blog created successfully', result });
  } catch (error) {
	res.status(500).json({ message: error.message });
  }
}

// get all blogs
export const GetBlogs = async (req: Request, res: Response) => {
  try {
	const result = await getBlogs();
	res.status(200).json({ message: 'Blogs fetched successfully', result });
  } catch (error) {
	res.status(500).json({ message: error.message });
  }
}

// get blog by id
export const GetBlogById = async (req: Request, res: Response) => {
  const id = Number(req.params.id);
  try {
	const result = await getBlogById(id);
	res.status(200).json({ message: 'Blog fetched successfully', result });
  } catch (error) {
	res.status(500).json({ message: error.message });
  }
}

// update blog by id
export const UpdateBlogById = async (req: Request, res: Response) => {
  const id = Number(req.params.id);
  const { title, content } = req.body;
  const blog = {
	title,
	content
  }
  try {
	const result = await updateBlogById(id, blog);
	res.status(200).json({ message: 'Blog updated successfully', result });
  } catch (error) {
	res.status(500).json({ message: error.message });
  }
}

// delete blog by id
export const DeleteBlogById = async (req: Request, res: Response) => {
  const id = Number(req.params.id);
  try {
	const result = await deleteBlogById(id);
	res.status(200).json({ message: 'Blog deleted successfully', result });
  } catch (error) {
	res.status(500).json({ message: error.message });
  }
}





